//
//  UserNotificationsHandler.m
//  sample-push-notifications
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "NotificationsProvider.h"
#import <UserNotifications/UserNotifications.h>
#import "SVProgressHUD.h"
#import <Quickblox/Quickblox.h>
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>

@interface NotificationsProvider() <UNUserNotificationCenterDelegate, PKPushRegistryDelegate>
@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) CXCallController *callController;
@property (strong, nonatomic) PKPushRegistry *voipRegistry;
@end

@implementation NotificationsProvider

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
        [self registerForRemoteNotifications];
        
        CXProviderConfiguration *configuration = [self configuration];
        self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
        self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        self.voipRegistry.delegate = self;
        self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    }
    return self;
}

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
    NSString *message = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];
    if (message) {
        return message;
    }
    return @"Unreadable message";
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSString *apnsMessage = [NSString stringWithFormat:@"APNS: %@", [self parseNotification:notification]];
    [center removeAllDeliveredNotifications];
    if ([self.delegate respondsToSelector:@selector(notificationsProvider:willPresentMessage:)]) {
        [self.delegate notificationsProvider:self willPresentMessage:apnsMessage];
    }
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSString *apnsMessage = [NSString stringWithFormat:@"APNS: %@", [self parseNotification:response.notification]];
    NSMutableArray *messages = [NSMutableArray arrayWithObject:apnsMessage];
    
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        for (UNNotification *notification in notifications) {
            if ([response.notification isEqual:notification]) {
                continue;
            }
            NSString *alertMessage = [NSString stringWithFormat:@"APNS: %@", [self parseNotification:notification]];
            [messages insertObject:alertMessage atIndex:0];
            [center removeAllDeliveredNotifications];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(notificationsProvider:didReceiveMessages:)]) {
                    [self.delegate notificationsProvider:self didReceiveMessages:messages];
                }
            });
        }
    }];
    completionHandler();
}

#pragma mark - VOIP
- (CXProviderConfiguration *)configuration {
    NSString *appName = @"ObjCPushes";
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = 1;
    config.maximumCallGroups = 1;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    config.ringtoneSound = @"ringtone.wav";
    return config;
}

#pragma mark - PKPushRegistryDelegate protocol
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [registry pushTokenForType:PKPushTypeVoIP];
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"[%@] Create Subscription request - Success",  NSStringFromClass([NotificationsProvider class]));
    } errorBlock:^(QBResponse *response) {
        NSLog(@"[%@] Create Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [QBRequest subscriptionsWithSuccessBlock:^(QBResponse * _Nonnull response, NSArray<QBMSubscription *> * _Nullable objects) {
        for (QBMSubscription *subscription in objects) {
            if ([subscription.deviceUDID isEqualToString:deviceIdentifier] && subscription.notificationChannel == QBMNotificationChannelAPNSVOIP) {
                [QBRequest deleteSubscriptionWithID:subscription.ID successBlock:^(QBResponse * _Nonnull response) {
                    NSLog(@"[%@] Unregister Subscription request - Success",  NSStringFromClass([NotificationsProvider class]));
                } errorBlock:^(QBResponse * _Nonnull response) {
                    NSLog(@"[%@] Unregister Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
                }];
                break;
            }
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"[%@] Get Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
    if (type == PKPushTypeVoIP && application.applicationState == UIApplicationStateActive) {
        
        NSString *message = @"VOIP PUSH from Admin";
        NSString *alertMessage = [payload.dictionaryPayload objectForKey:@"alertMessage"];
        if (alertMessage) {
            message = alertMessage;
        }
        NSString *voipMessage = [NSString stringWithFormat:@"VOIP: %@", message];
        if ([self.delegate respondsToSelector:@selector(notificationsProvider:didReceiveIncomingVOIPPushWithMessage:)]) {
            [self.delegate notificationsProvider:self didReceiveIncomingVOIPPushWithMessage:voipMessage];
        }
    }
    if (completion) {
        completion();
    }
}

@end
