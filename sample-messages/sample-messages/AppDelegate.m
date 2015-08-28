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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    //
    [QBApplication sharedApplication].applicationId = 92;
    [QBConnection registerServiceKey:@"wJHdOcQSxXQGWx5"];
    [QBConnection registerServiceSecret:@"BTFsj7Rtt27DAmT"];
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    
    // Get push alert
    NSString *message = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];
    NSMutableDictionary *pushInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushDidReceive" object:nil userInfo:pushInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //  New way, only for updated backends
    //
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

//    // Old way
//    //
//    [QBRequest registerSubscriptionForDeviceToken:deviceToken uniqueDeviceIdentifier:deviceIdentifier
//                                     successBlock:^(QBResponse *response, NSArray *subscriptions) {
//                                         NSLog(@"Successfull response!");
//                                     } errorBlock:^(QBError *error) {
//                                         NSLog(@"Response error:%@", error);
//                                         
//                                         
//                                     }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [ViewController showAlertViewWithErrorMessage:[error localizedDescription]];
    
    [SVProgressHUD dismiss];
}

@end
