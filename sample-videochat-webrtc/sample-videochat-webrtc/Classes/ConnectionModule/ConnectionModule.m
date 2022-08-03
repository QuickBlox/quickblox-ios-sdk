//
//  Connection.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 06.10.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "ConnectionModule.h"
#import "Profile.h"
#import <arpa/inet.h>

@interface ConnectionModule ()

@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, assign, readonly) BOOL isNetworkLost;

@property (nonatomic, assign) BOOL activeCall;

@end

@interface ConnectionModule (ChatConnection) <QBChatDelegate>
@end

@implementation ConnectionModule

- (SCNetworkReachabilityRef)reachability {
    if (_reachability) {
        return _reachability;
    }
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    
    _reachability =
    SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);
    return _reachability;
}

- (BOOL)isNetworkLost {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachability, &flags)) {
        
        return (flags & kSCNetworkReachabilityFlagsReachable) == 0;
    }
    return NO;
}

- (BOOL)tokenHasExpired {
    return QBSession.currentSession.tokenHasExpired;
}

- (BOOL)established {
    BOOL connected = NO;
    if (self.tokenHasExpired == NO && QBChat.instance.isConnected) {
        connected = YES;
    }

    if (connected == NO) {
        [self establishConnection];
    }
    return connected;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isProcessing = NO;
        self.activeCall = NO;
        QBSettings.autoReconnectEnabled = YES;
        QBSettings.networkIndicatorManagerEnabled = YES;
        [QBChat.instance addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [QBChat.instance removeDelegate:self];
}

//MARK: - Actions
- (void)activateAutomaticMode {
    [self establishConnection];
}

- (void)activateCallMode {
    self.activeCall = YES;
}

- (void)deactivateCallMode {
    self.activeCall = NO;
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        return;
    }
}

- (void)establishConnection {
    Profile *profile = [[Profile alloc] init];
    [self connectWithId:profile.ID
               password:profile.password];
}

- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion {
    if (self.isProcessing) {
        return;
    }
    self.isProcessing = YES;
    
    if (QBChat.instance.isConnected == NO) {
        [self logoutWithCompletion:completion];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [QBChat.instance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        [weakSelf logoutWithCompletion:completion];
    }];
}

//MARK: - Internal
- (void)logoutWithCompletion:(nonnull void (^)(void))completion {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        weakSelf.isProcessing = NO;
        completion();
    } errorBlock:^(QBResponse * _Nonnull response) {
        weakSelf.isProcessing = NO;
        completion();
    }];
}

- (void)connectWithId:(NSUInteger)id password:(NSString *)password {
    if (QBChat.instance.isConnected || QBChat.instance.isConnecting) {
        return;
    }
    [QBChat.instance connectWithUserID:id
                              password:password
                            completion:nil];
    return;
}

- (void)disconnect {
    if (QBChat.instance.isConnected == NO) {
        return;
    }
    [QBChat.instance disconnectWithCompletionBlock:nil];
}

@end

@implementation ConnectionModule (ChatConnection)

- (void)chatDidConnect {
    if (self.onConnect) { self.onConnect(); }
}

- (void)chatDidNotConnectWithError:(NSError *)error {
    if (error == nil) {
        return;
    }
    if (self.onDisconnect) {
        self.onDisconnect(self.isNetworkLost);
    }
}

- (void)chatDidDisconnectWithError:(NSError *)error {
    if (error == nil) {
        return;
    }
    if (self.onDisconnect) {
        self.onDisconnect(self.isNetworkLost);
    }
}

- (void)chatDidReconnect {
    if (self.onConnect) { self.onConnect(); }
}

@end
