//
//  UserNotificationsHandler.m
//  sample-conference-videochat
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "NotificationsProvider.h"
#import <UserNotifications/UserNotifications.h>
#import "SVProgressHUD.h"
#import <Quickblox/Quickblox.h>

@interface NotificationsProvider() <UNUserNotificationCenterDelegate>
@end

@implementation NotificationsProvider


#pragma mark - APNS
- (void)registerForRemoteNotifications {
    // Enable push notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
                if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:error.description];
        }
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
    if ([self.delegate respondsToSelector:@selector(notificationsProvider:willPresentMessage:)]) {
        [self.delegate notificationsProvider:self willPresentMessage:[self parseNotification:notification]];
    }
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
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
