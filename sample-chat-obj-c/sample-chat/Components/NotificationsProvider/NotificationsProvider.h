//
//  UserNotificationsHandler.h
//  sample-chat
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kSubscriptionID = @"last_apns_subscription_id";
static NSString * const kToken = @"last_apns_token";
static NSString * const kNeedUpdateToken = @"last_apns_token_need_update";

typedef NS_ENUM(NSUInteger, PushType) {
    PushTypeAPNS,
    PushTypeAPNSVOIP
};

typedef void(^DeleteSubscriptionCompletion)(void);

@class NotificationsProvider;

@protocol NotificationsProviderDelegate <NSObject>
@optional
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceive:(NSString *)dialogID;
@end

@interface NotificationsProvider : NSObject
@property (nonatomic, weak) id <NotificationsProviderDelegate> delegate;

+ (void)prepareSubscriptionWithToken:(NSData *)token;
+ (void)createSubscriptionWithToken:(NSData *)token;
+ (void)deleteLastSubscriptionWithCompletion:(DeleteSubscriptionCompletion)completion;

- (void)registerForRemoteNotifications;
@end

NS_ASSUME_NONNULL_END
