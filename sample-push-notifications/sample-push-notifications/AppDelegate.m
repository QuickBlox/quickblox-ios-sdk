//
//  AppDelegate.m
//  sample-messages
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

const NSUInteger kApplicationID = 72448;
NSString *const kAuthKey        = @"f4HYBYdeqTZ7KNb";
NSString *const kAuthSecret     = @"ZC7dK39bOjVc-Z8";
NSString *const kAccountKey     = @"C4_z7nuaANnBYmsG_k98";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
    
    @end

@implementation AppDelegate
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    //
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    [self registerForRemoteNotifications];
    return YES;
}
    
#pragma mark - Remote Notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
    
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    {
        NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
        
        // Get push alert
        [self postPushNotificationWithUserInfo:userInfo];
    }
    
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification userInfo=%@ completionHandler", userInfo);
    [self postPushNotificationWithUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNoData);
}
    
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //  New way, only for updated backends
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
        NSLog(@"Successfull response!");
        [SVProgressHUD dismiss];
        
    } errorBlock:^(QBResponse *response) {
        
        [ViewController showAlertViewWithErrorMessage:[response.error description]];
        
        [SVProgressHUD dismiss];
    }];
}
    
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [ViewController showAlertViewWithErrorMessage:[error localizedDescription]];
    
    [SVProgressHUD dismiss];
}
    
#pragma mark - UNUserNotificationCenterDelegate iOS 10+
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}
    
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    completionHandler();
}
    
#pragma mark - Remote Notifications Help
- (void)registerForRemoteNotifications {
    if (@available(iOS 10, *)) {
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
                                      [ViewController showAlertViewWithErrorMessage:[error description]];
                                  }
                              }];
    } else {
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert |
                                                      UIUserNotificationTypeBadge)
                                          categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}
    
- (void)postPushNotificationWithUserInfo:(NSDictionary *)userInfo {
    NSString *message = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];
    NSMutableDictionary *pushInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushDidReceive" object:nil userInfo:pushInfo];
}
    
    @end
