//
//  AppDelegate.m
//  SimpleSample-messages_users-ios
//
//  Created by Igor Khomenko on 2/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSMAppDelegate.h"
#import "SSMSplashViewController.h"

@interface SSMAppDelegate()

@property (strong, nonatomic) SSMSplashViewController* splashViewController;

@end

@implementation SSMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBApplication sharedApplication].applicationId = 92;
    [QBConnection registerServiceKey:@"wJHdOcQSxXQGWx5"];
    [QBConnection registerServiceSecret:@"BTFsj7Rtt27DAmT"];
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.splashViewController = [[SSMSplashViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:self.splashViewController];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    
    // Get push alert
    NSString *message = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];
    
    NSMutableDictionary *pushInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    
    // get push rich content
    NSString *richContent = userInfo[@"rich_content"];
    if(richContent != nil){
        pushInfo[@"rich_content"] = richContent;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushDidReceive object:nil userInfo:pushInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [QBRequest registerSubscriptionForDeviceToken:deviceToken uniqueDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                     successBlock:^(QBResponse *response, NSArray *subscriptions) {
    } errorBlock:^(QBError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[error.reasons description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
