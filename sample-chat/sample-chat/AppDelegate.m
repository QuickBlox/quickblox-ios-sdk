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
#import "STKStickerPipe.h"
#import <SSKeychain/SSKeychain.h>
#import "NSString+MD5.h"

const NSUInteger kApplicationID = 28783;
NSString *const kAuthKey        = @"b5bVGCHHv6rcAmD";
NSString *const kAuthSecret     = @"ySwEpardeE7ZXHB";
NSString *const kAccountKey     = @"7yvNe17TnjNUqDoPwfqp";

@interface AppDelegate () <NotificationServiceDelegate>

@end

@implementation AppDelegate 

-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}


- (NSString *)userId {
    
    NSString  *currentDeviceId = [self getUniqueDeviceIdentifierAsString];

    return [currentDeviceId MD5Digest];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    [QBSettings setChatDNSLookupCacheEnabled:YES];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    
    
    [STKStickersManager initWitApiKey: @"847b82c49db21ecec88c510e377b452c"];
    [STKStickersManager setStartTimeInterval];
    [STKStickersManager setUserKey:[self userId]];
    
    [STKStickersManager setUserIsSubscriber:NO];
    // app was launched from push notification, handling it
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        ServicesManager.instance.notificationService.pushDialogID = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][kPushNotificationDialogIdentifierKey];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // subscribing for push notifications
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        //
    } errorBlock:^(QBResponse *response) {
        //
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // failed to register push
    NSLog(@"Push failed to register with error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([application applicationState] == UIApplicationStateInactive)
    {
        NSString *dialogID = userInfo[kPushNotificationDialogIdentifierKey];
        if (dialogID != nil) {
            NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
            if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
            
            ServicesManager.instance.notificationService.pushDialogID = dialogID;
            
            // calling dispatch async for push notification handling to have priority in main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [ServicesManager.instance.notificationService handlePushNotificationWithDelegate:self];
            });
        }
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
	[ServicesManager.instance.chatService disconnectWithCompletionBlock:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
    // Login to QuickBlox Chat
    //
	[ServicesManager.instance.chatService connectWithCompletionBlock:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NotificationServiceDelegate protocol

- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    
    ChatViewController *chatController = (ChatViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.dialog = chatDialog;
    
    NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
    if (dialogWithIDWasEntered != nil) {
        // some chat already opened, return to dialogs view controller first
        [navigationController popViewControllerAnimated:NO];
    }
    
    [navigationController pushViewController:chatController animated:YES];
}

@end
