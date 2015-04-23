//
//  AppDelegate.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "AppDelegate.h"

#import "AuthModuleViewController.h"
#import "UsersModuleViewController.h"
#import "RatingsModuleViewController.h"
#import "LocationModuleViewController.h"
#import "MessagesModuleViewController.h"
#import "ContentModuleViewController.h"
#import "ChatModuleViewController.h"
#import "CustomObjectsModuleViewController.h"

@interface AppDelegate() <QBChatDelegate>

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1 = [[AuthModuleViewController alloc] initWithNibName:@"AuthModuleViewController" bundle:nil];
    UIViewController *viewController2 = [[UsersModuleViewController alloc] initWithNibName:@"UsersModuleViewController" bundle:nil];
    UIViewController *viewController3 = [[LocationModuleViewController alloc] initWithNibName:@"LocationModuleViewController" bundle:nil];
    UIViewController *viewController4 = [[MessagesModuleViewController alloc] initWithNibName:@"MessagesModuleViewController" bundle:nil];
    UIViewController *viewController5 = [[RatingsModuleViewController alloc] initWithNibName:@"RatingsModuleViewController" bundle:nil];
    UIViewController *viewController6 = [[ContentModuleViewController alloc] initWithNibName:@"ContentModuleViewController" bundle:nil];
    UIViewController *viewController7 = [[ChatModuleViewController alloc] initWithNibName:@"ChatModuleViewController" bundle:nil];
    UIViewController *viewController8 = [[CustomObjectsModuleViewController alloc] initWithNibName:@"CustomObjectsModuleViewController" bundle:nil];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController8, viewController7, viewController4, viewController6,
                                             viewController5, viewController3, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // show Chat
    self.tabBarController.selectedIndex = 3;

    // Setup QuickBlox application
    //
    [QBApplication sharedApplication].applicationId = [[ConfigManager sharedManager] appId];
    [QBConnection registerServiceKey:[[ConfigManager sharedManager] authKey]];
    [QBConnection registerServiceSecret:[[ConfigManager sharedManager] authSecret]];
    [QBSettings setAccountKey:[[ConfigManager sharedManager] accountKey]];
    //

    [QBConnection setApiDomain:[[ConfigManager sharedManager] apiDomain] forServiceZone:QBConnectionZoneTypeProduction];
    [QBConnection setServiceZone:QBConnectionZoneTypeProduction];
    
    [QBConnection setAutoCreateSessionEnabled:YES];
    
    [QBSettings setServerChatDomain:[[ConfigManager sharedManager] chatDomain]];
    [QBSettings setContentBucket:[[ConfigManager sharedManager] bucketName]];
    
#ifndef DEBUG
    [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
#endif
    
    [QBConnection setNetworkIndicatorManagerEnabled:YES];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (useNewAPI) {
        [QBRequest registerSubscriptionForDeviceToken:deviceToken uniqueDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                         successBlock:^(QBResponse *response, NSArray *subscriptions) {
            NSLog(@"Successfull response!");
        } errorBlock:^(QBError *error) {
            NSLog(@"Response error:%@", error);
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // userInfo
    NSLog(@"New Push received\n: %@", userInfo);
}


@end
