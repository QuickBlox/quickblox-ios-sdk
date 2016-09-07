//
//  AppDelegate.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "QBCore.h"

const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 30.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window.backgroundColor = [UIColor whiteColor];
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    [QBSettings setApplicationID:39854];
    [QBSettings setAuthKey:@"JtensAa9y4AM5Yk"];
    [QBSettings setAuthSecret:@"AsDFwwwxpr3LN5w"];
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [QBRTCClient initializeRTC];
    
    return YES;
}

#pragma mark - Remote Notifictions

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        
        NSLog(@"Did register user notificaiton settings");
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Did register for remote notifications with device token");
    [Core registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"Did receive remote notification %@", userInfo);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Did fail to register for remote notification with error %@", error.localizedDescription);
}

@end
