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

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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

    // Setun QuickBlox application
    //
    [QBSettings setApplicationID:AppID];
    [QBSettings setAuthorizationKey:AuthKey];
    [QBSettings setAuthorizationSecret:AuthSecret];
    [QBSettings setAccountKey:AccountKey];
    [QBSettings setServerApiDomain:ServerApiDomain];
    [QBSettings setServerChatDomain:ServerChatDomain];
#ifndef DEBUG
    [QBSettings  useProductionEnvironmentForPushNotifications:YES];
#endif
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[QBChat instance] logout];
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
