//
//  AppDelegate.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "Log.h"
#import "PresenterViewController.h"
#import "NotificationsProvider.h"

@import Quickblox;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    
    [Quickblox initWithApplicationId:0
                             authKey:@""
                          authSecret:@""
                          accountKey:@""];
    // enabling carbons for chat
    [QBSettings setCarbonsEnabled:YES];
    [QBSettings setAutoReconnectEnabled:YES];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[PresenterViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [NotificationsProvider.class prepareSubscriptionWithToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // failed to register push
    Log(@"Push failed to register with error: %@", error);
}

@end
