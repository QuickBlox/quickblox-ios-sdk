//
//  AppDelegate.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "AppDelegate.h"
#import "ServicesManager.h"
#import "ChatViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBApplication sharedApplication].applicationId = 92;
    [QBConnection registerServiceKey:@"wJHdOcQSxXQGWx5"];
    [QBConnection registerServiceSecret:@"BTFsj7Rtt27DAmT"];
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
		
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger defaultsUserID = [defaults integerForKey:@"userID"];
    
    // if user logged in with different userID
    if (defaultsUserID && ServicesManager.instance.currentUser.ID != defaultsUserID) {
        [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:nil errorBlock:nil];
        // force update defaultsUserID
        defaultsUserID = 0;
    }
    
    // if userID is not stored
    if (!defaultsUserID) {
        [defaults setInteger:ServicesManager.instance.currentUser.ID forKey:@"userID"];
        [defaults synchronize];
    }
    
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Subscription creation: SUCCESS");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Subscription creation: ERROR");
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // failed to register push
    NSLog(@"Failed to register PUSH: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([application applicationState] == UIApplicationStateInactive)
    {
        NSLog(@"Received notifications while inactive.");
        NSLog(@"New push: %@", userInfo);
        
        NSString *dialogID = userInfo[@"dialog_id"];
        
        if ([dialogID isEqualToString:[ServicesManager instance].currentDialogID])
            return;
        
        if (userInfo[@"dialog_id"]) {
            // initializing dialog from push
            QBChatDialog *dialog = [[QBChatDialog alloc] initWithDialogID:userInfo[@"dialog_id"] type:[userInfo[@"dialog_type"] intValue]];
            dialog.occupantIDs = userInfo[@"dialog_occupants"];
            
            // opening chat controller with dialog
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController *chatController = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatController.didRecieveChatFromPush = YES;
            chatController.dialog = dialog;
            [(UINavigationController*)self.window.rootViewController pushViewController:chatController animated:NO];
        }
    }
    else
    {
        NSLog(@"Received notifications while active.");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Logout from chat
    //
	[ServicesManager.instance.chatService logoutChat];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
    // Login to QuickBlox Chat
    //
	[ServicesManager.instance.chatService logIn:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
