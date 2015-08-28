//
//  AppDelegate.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "AppDelegate.h"
#import "DialogsViewController.h"
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
	[ServicesManager.instance.chatService logIn:^(NSError *error) {
		if (!error) {
			for (QBChatDialog *dialog in [ServicesManager.instance.chatService.dialogsMemoryStorage unsortedDialogs]) {
				if (dialog.type == QBChatDialogTypeGroup && !dialog.isJoined) {
                    // Joining to group chat dialogs.
                    [[ServicesManager instance].chatService joinToGroupDialog:dialog failed:^(NSError *error) {
                        NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                    }];
				}
			}
		}
	}];
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
