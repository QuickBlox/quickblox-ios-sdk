//
//  QBCore.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 03/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBCore.h"
#import "QBProfile.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

NSString *const QB_DEFAULT_PASSOWORD = @"x6Bt0VDy5";

@interface QBCore() <QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QBCoreDelegate> *multicastDelegate;
@property (strong, nonatomic) QBProfile *profile;

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t reachabilitySerialQueue;

@property (assign, nonatomic) BOOL isAutorized;

@end

@implementation QBCore

+ (instancetype)instance {
    
    static QBCore *_core = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _core = [QBCore alloc];
        [_core commonInit];
    });
    
    return _core;
}

- (void)commonInit {
    
    _multicastDelegate = (id<QBCoreDelegate>)[[QBMulticastDelegate alloc] init];
    _profile = [QBProfile currentProfile];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [[QBChat instance] addDelegate:self];
    
    [self startReachabliyty];
}

- (void)clearProfile {
    [self.profile clearProfile];
}

- (void)addDelegate:(id <QBCoreDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

#pragma mark - QBChatDelegate

- (void)chatDidNotConnectWithError:(QB_NULLABLE NSError *)error {
    
}

- (void)chatDidFailWithStreamError:(QB_NULLABLE NSError *)error {
    
}

- (void)chatDidAccidentallyDisconnect {
}

- (void)chatDidReconnect {
    
}

#pragma mark - Current User

- (QBUUser *)currentUser {
    
    return self.profile.userData;
}

- (void)setLoginStatus:(NSString *)loginStatus {
    
    if ([self.multicastDelegate respondsToSelector:@selector(core:loginStatus:)]) {
        [self.multicastDelegate core:self loginStatus:loginStatus];
    }
}

- (void)loginWithCurrentUser {
    
    dispatch_block_t connectToChat = ^{
        
        self.currentUser.password = QB_DEFAULT_PASSOWORD;
        QBUUser *user = self.currentUser;
        
        [self setLoginStatus:@"Login into chat ..."];
        
        [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
            
            if (error) {
                
                if (error.code == 401) {
                    
                    self.isAutorized = NO;
                    // Clean profile
                    [self.profile clearProfile];
                    // Notify about logout
                    if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogout:)]) {
                        [self.multicastDelegate coreDidLogout:self];
                    }
                }
                else {
                    [self handleError:error domain:ErrorDomainLogIn];
                }
            }
            else {
                
                if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogin:)]) {
                    [self.multicastDelegate coreDidLogin:self];
                }
            }
        }];
    };
    
    if (self.isAutorized) {
        
        connectToChat();
        return;
    }
    
    [self setLoginStatus:@"Login with curretn user ..."];
    [QBRequest logInWithUserLogin:self.currentUser.login
                         password:QB_DEFAULT_PASSOWORD
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user)
     {
         self.isAutorized = YES;
         
         connectToChat();
         
         [self registerForRemoteNotifications];
         
     } errorBlock:^(QBResponse * _Nonnull response) {
         
         [self handleError:response.error.error domain:ErrorDomainLogIn];
         
         if (response.status == QBResponseStatusCodeUnAuthorized) {
             // Clean profile
             [self.profile clearProfile];
         }
     }];
}

- (void)signUpWithFullName:(NSString *)fullName
                  roomName:(NSString *)roomName {
    
    NSParameterAssert(!self.currentUser);
    
    QBUUser *newUser = [QBUUser user];
    
    newUser.login = [NSUUID UUID].UUIDString;
    newUser.fullName = fullName;
    newUser.tags = @[roomName].mutableCopy;
    newUser.password = QB_DEFAULT_PASSOWORD;
    
    [self setLoginStatus:@"Signg up ..."];
    
    [QBRequest signUp:newUser
         successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user)
     {
         [self.profile synchronizeWithUserData:user];
         [self loginWithCurrentUser];
         
     } errorBlock:^(QBResponse * _Nonnull response) {
         
         [self handleError:response.error.error domain:ErrorDomainSignUp];
     }];
}

- (void)logout {
    
    dispatch_group_t logoutGroup = dispatch_group_create();
    
    dispatch_group_enter(logoutGroup);
    [self unsubscribeFromRemoteNotifications:^{
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_enter(logoutGroup);
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_notify(logoutGroup, dispatch_get_main_queue(), ^ {
        // Delete user from server
        [QBRequest deleteCurrentUserWithSuccessBlock:^(QBResponse * _Nonnull response) {
            
            self.isAutorized = NO;
            // Clean profile
            [self.profile clearProfile];
            // Notify about logout
            if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogout:)]) {
                [self.multicastDelegate coreDidLogout:self];
            }
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
            [self handleError:response.error.error domain:ErrorDomainLogOut];
        }];
    });
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType type = (UIUserNotificationTypeSound |
                                       UIUserNotificationTypeAlert |
                                       UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:type
                                          categories:nil];
        
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    }
}

- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSParameterAssert(deviceToken);
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void)unsubscribeFromRemoteNotifications:(dispatch_block_t)completionBlock {
    
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                  successBlock:^(QBResponse * _Nonnull response)
     {
         if (completionBlock) {
             completionBlock();
         }
         
     } errorBlock:^(QBError * _Nullable error) {
         
         if (completionBlock) {
             completionBlock();
         }
     }];
}

#pragma mark - Handle errors

- (void)handleError:(NSError *)error domain:(ErrorDomain)domain {
    
    if ([self.multicastDelegate respondsToSelector:@selector(core:error:domain:)]) {
        [self.multicastDelegate core:self error:error domain:domain];
    }
}

#pragma mark - Reachability

- (void)startReachabliyty {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    _reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)self;
    
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, CoreReachabilityCallback, &context)) {
        
        self.reachabilitySerialQueue = dispatch_queue_create("com.quickblox.samplecore.reachability", NULL);
        // Set it as our reachability queue, which will retain the queue
        if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
            
        }
        else {
            
            NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
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
    
    //    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return QBNetworkStatusNotReachable;
    }
    
    QBNetworkStatus returnValue = QBNetworkStatusNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
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
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = QBNetworkStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = QBNetworkStatusReachableViaWWAN;
    }
    
    return returnValue;
}

// Start listening for reachability notifications on the current run loop
static void CoreReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    
    QBCore *core = ((__bridge QBCore*)info);
    
    @autoreleasepool {
        
        [core reachabilityChanged:flags];
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
