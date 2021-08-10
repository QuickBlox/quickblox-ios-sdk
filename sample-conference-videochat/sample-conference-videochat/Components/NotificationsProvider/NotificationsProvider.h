//
//  UserNotificationsHandler.h
//  sample-conference-videochat
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PushType) {
    PushTypeAPNS,
    PushTypeAPNSVOIP
};

@class NotificationsProvider;

@protocol NotificationsProviderDelegate <NSObject>
@optional
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceive:(NSString *)message;
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider willPresentMessage:(NSString *)message;
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceiveIncomingVOIPPushWithMessage:(NSString *)message;

@end

@interface NotificationsProvider : NSObject
@property (nonatomic, weak) id <NotificationsProviderDelegate> delegate;

- (void)registerForRemoteNotifications;
@end

NS_ASSUME_NONNULL_END
