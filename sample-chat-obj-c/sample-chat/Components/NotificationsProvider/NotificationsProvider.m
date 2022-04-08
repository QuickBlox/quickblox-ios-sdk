//
//  UserNotificationsHandler.m
//  sample-chat
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "NotificationsProvider.h"
#import <UserNotifications/UserNotifications.h>
#import <Quickblox/Quickblox.h>
#import "AppDelegate.h"
#import "Log.h"

@interface NotificationsProvider() <UNUserNotificationCenterDelegate>
@end

@implementation NotificationsProvider

#pragma mark - APNS
+ (void)prepareSubscriptionWithToken:(NSData *)token {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    NSData *lastToken = [userDefaults objectForKey:kToken];
    if ([lastToken isEqualToData:token]) {
        return;
    }
    
    [userDefaults setObject:token forKey:kToken];
    [userDefaults setBool:YES forKey:kNeedUpdateToken];

    __weak __typeof(self)weakSelf = self;
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf createSubscriptionWithToken:token];
    }];
}

+ (void)createSubscriptionWithToken:(NSData *)token {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = token;

    [QBRequest createSubscription:subscription
                     successBlock:^(QBResponse *response, NSArray *objects) {
        QBMSubscription *newSubscription = nil;
        for (QBMSubscription *subscription in objects) {
            if (subscription.notificationChannel == QBMNotificationChannelAPNS &&
                [subscription.deviceUDID isEqualToString:deviceIdentifier]) {
                newSubscription = subscription;
            }
        }
        
        [NSUserDefaults.standardUserDefaults setObject:@(newSubscription.ID) forKey:kSubscriptionID];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:kNeedUpdateToken];
        Log(@"[%@] Create Subscription request - Success",  NSStringFromClass([NotificationsProvider class]));
    } errorBlock:^(QBResponse *response) {
        Log(@"[%@] Create Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
    }];
}

+ (void)deleteLastSubscriptionWithCompletion:(DeleteSubscriptionCompletion)completion {
    NSNumber *lastSubscriptionId = [NSUserDefaults.standardUserDefaults objectForKey:kSubscriptionID];
    if (lastSubscriptionId == nil) {
        if (completion) { completion(); }
        return;
    }
    
    [QBRequest deleteSubscriptionWithID:lastSubscriptionId.unsignedIntValue
                           successBlock:^(QBResponse * _Nonnull response) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kSubscriptionID];
        Log(@"[%@] Delete Subscription request - Success",  NSStringFromClass([NotificationsProvider class]));
        if (completion) { completion(); }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Delete Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
        if (completion) { completion(); }
    }];
}

- (void)registerForRemoteNotifications {
    // Enable push notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            return;
        }
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }];
}

- (NSString *)parseNotification:(UNNotification *)notification {
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSString *dialogID = userInfo[@"dialog_id"];
    
    if (dialogID.length == 0) {
        return @"";
    }
    return dialogID;
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    [center removeAllDeliveredNotifications];
    if ([self.delegate respondsToSelector:@selector(notificationsProvider:didReceive:)]) {
        [self.delegate notificationsProvider:self didReceive:[self parseNotification:notification]];
    }
    completionHandler(UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateActive) {
        completionHandler();
        return;
    }
    if ([self.delegate respondsToSelector:@selector(notificationsProvider:didReceive:)]) {
        [self.delegate notificationsProvider:self didReceive:[self parseNotification:response.notification]];
    }
    completionHandler();
}

@end
