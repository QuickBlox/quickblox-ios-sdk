//
//  AppDelegate.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "Log.h"
#import <UserNotifications/UserNotifications.h>
#import "ChatManager.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "RootParentVC.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"

// To update the QuickBlox credentials, please see the READMe file.(You must create application in admin.quickblox.com)
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    // enabling carbons for chat
    [QBSettings setCarbonsEnabled:YES];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[RootParentVC alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:nil errorBlock:nil];
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    [center removeAllDeliveredNotifications];
    [center removeAllPendingNotificationRequests];
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        completionHandler();
        return;
    }
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSString *dialogID = userInfo[NSLocalizedString(@"SA_STR_PUSH_NOTIFICATION_DIALOG_ID", nil)];
    
    if (dialogID.length == 0) {
        completionHandler();
        return;
    }

    // calling dispatch async for push notification handling to have priority in main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        QBChatDialog *chatDialog = [ChatManager.instance.storage dialogWithID:dialogID];
        if ([self.window.rootViewController isKindOfClass:[RootParentVC class]]) {
            RootParentVC *rootParentVC = (RootParentVC *)self.window.rootViewController;
            if (chatDialog) {
                rootParentVC.dialogID = dialogID;
            } else {
                [ChatManager.instance loadDialogWithID:dialogID completion:^(QBChatDialog * _Nonnull loadedDialog) {
                    if (!loadedDialog) {
                        return;
                    }
                    rootParentVC.dialogID = dialogID;
                }];
            }
        }
    });
    
    completionHandler();
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // failed to register push
    Log(@"Push failed to register with error: %@", error);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    application.applicationIconBadgeNumber = 0;
    
    // Logout from chat
    [ChatManager.instance disconnect:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Login to QuickBlox Chat
    [ChatManager.instance connect:nil];
}

@end
