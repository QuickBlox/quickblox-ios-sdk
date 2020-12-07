//
//  AppDelegate.m
//  sample-push-notifications
//
//  Created by Injoit on 6/11/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>
#import "RootParentVC.h"

//To update the Credentials, please see the README file.
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[RootParentVC alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Remote Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //  New way, only for updated backends
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        [SVProgressHUD dismiss];
        
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:response.error.description];
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
