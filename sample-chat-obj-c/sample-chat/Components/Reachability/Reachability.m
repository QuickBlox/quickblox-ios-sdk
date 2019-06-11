//
//  Reachability.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "Reachability.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Log.h"

@interface Reachability()

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t reachabilitySerialQueue;

@end

@implementation Reachability

//MARK: - Life Cycle
+ (instancetype)instance {
    
    static Reachability *_reachability = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _reachability = [[Reachability alloc] init];
        [_reachability commonInit];
    });
    
    return _reachability;
}

//MARK - Setup
- (void)commonInit {
    [QBSettings setAutoReconnectEnabled:YES];
    [self startReachabliyty];
}

//MARK: - Actions
- (void)startReachabliyty {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    _reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)self;
    
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context)) {
        self.reachabilitySerialQueue = dispatch_queue_create("com.quickblox.samplecore.reachability", NULL);
        // Set it as our reachability queue, which will retain the queue
        if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
        } else {
            Log(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
            SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        }
    }
}

- (QBNetworkStatus)networkStatus {
    
    if (_reachabilityRef != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
            
            return [self networkStatusForFlags:flags];
        }
    }
    
    return NO;
}

- (QBNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return QBNetworkStatusNotReachable;
    }
    
    QBNetworkStatus returnValue = QBNetworkStatusNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = QBNetworkStatusReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = QBNetworkStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = QBNetworkStatusReachableViaWWAN;
    }
    
    return returnValue;
}

// Start listening for reachability notifications on the current run loop
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    Reachability *reachability = ((__bridge Reachability*)info);
    @autoreleasepool {
        [reachability reachabilityChanged:flags];
    }
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.networkStatusBlock) {
            self.networkStatusBlock([self networkStatusForFlags:flags]);
        }
    });
}

@end
