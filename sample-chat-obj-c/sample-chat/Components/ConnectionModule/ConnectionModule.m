//
//  Connection.m
//  sample-chat
//
//  Created by Injoit on 06.10.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "ConnectionModule.h"
#import "Profile.h"
#import <arpa/inet.h>

static NSInteger const ALREADY_CONNECTED_CODE = -1000;

@interface ConnectionModule ()

@property (nonatomic, strong) id appActiveStateObserver;
@property (nonatomic, strong) id appInactiveStateObserver;

@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, assign, readonly) BOOL isNetworkLost;

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

- (id)appActiveStateObserver {
    if (_appActiveStateObserver) {
        return _appActiveStateObserver;
    }
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    __weak __typeof(self)weakSelf = self;
    _appActiveStateObserver = [center addObserverForName:UIApplicationWillEnterForegroundNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf establish];
    }];
    return _appActiveStateObserver;
}

- (id)appInactiveStateObserver {
    if (_appInactiveStateObserver) {
        return _appInactiveStateObserver;
    }
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    __weak __typeof(self)weakSelf = self;
    _appInactiveStateObserver = [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf disconnect];
    }];

    return _appInactiveStateObserver;
}

- (BOOL)tokenHasExpired {
    return QBSession.currentSession.tokenHasExpired;
}

- (BOOL)established {
    BOOL connected = NO;
    if (self.tokenHasExpired == NO && QBChat.instance.isConnected) {
        connected = YES;
    }
    return connected;
}

- (instancetype)init {
    self = [super init];
    if (self) {
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
    [self appActiveStateObserver];
    
    [self appInactiveStateObserver];
    
    [self establish];
}

- (void)deactivateAutomaticMode {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self.appActiveStateObserver];
    [center removeObserver:self.appInactiveStateObserver];
}

- (void)establish {
    if (self.tokenHasExpired ) {
        [self disconnect];
        if ([self.delegate respondsToSelector:@selector(connectionModuleTokenHasExpired:)]) {
            [self.delegate connectionModuleTokenHasExpired:self];
        }
        return;
    }
    if (QBChat.instance.isConnected) {
        if ([self.delegate respondsToSelector:@selector(connectionModuleDidConnect:)]) {
            [self.delegate connectionModuleDidConnect:self];
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(connectionModuleWillConnect:)]) {
        [self.delegate connectionModuleWillConnect:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    [QBChat.instance connectWithUserID:QBSession.currentSession.sessionDetails.userID
                              password:QBSession.currentSession.sessionDetails.token
                            completion:^(NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (error && error.code != ALREADY_CONNECTED_CODE) {
            if ([strongSelf.delegate respondsToSelector:@selector(connectionModuleDidNotConnect:withError:)]) {
                [strongSelf.delegate connectionModuleDidNotConnect:strongSelf withError:error];
            }
            return;
        }
        
        if ([strongSelf.delegate respondsToSelector:@selector(connectionModuleDidConnect:)]) {
            [strongSelf.delegate connectionModuleDidConnect:strongSelf];
        }
    }];
}

- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion {
    if (QBChat.instance.isConnected == NO) {
        completion();
        return;
    }
    [QBChat.instance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        completion();
    }];
}

//MARK: - Internal
- (void)disconnect {
    if (QBChat.instance.isConnected == NO) {
        return;
    }
    [QBChat.instance disconnectWithCompletionBlock:nil];
}

@end

@implementation ConnectionModule (ChatConnection)

- (void)chatDidNotConnectWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(connectionModuleDidNotConnect:withError:)]) {
        [self.delegate connectionModuleDidNotConnect:self withError:error];
    }
}

- (void)chatDidDisconnectWithError:(NSError *)error {
    if (error == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(connectionModuleDidNotConnect:withError:)]) {
        [self.delegate connectionModuleDidNotConnect:self withError:error];
    }
}

- (void)chatDidReconnect {
    if ([self.delegate respondsToSelector:@selector(connectionModuleDidReconnect:)]) {
        [self.delegate connectionModuleDidReconnect:self];
    }
}

- (void)chatDidAccidentallyDisconnect {
    if ([self.delegate respondsToSelector:@selector(connectionModuleWillConnect:)]) {
        [self.delegate connectionModuleWillConnect:self];
    }
}

@end
