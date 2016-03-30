//
//  AppDelegate.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "PushMessagesManager.h"
#import "ChatManager.h"
#import "UsersDataSource.h"
#import "Settings.h"
#import "SampleCoreManager.h"
#import "Settings.h"
#import "QMSoundManager.h"

const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;

@implementation AppDelegate

#ifdef DEBUG
void eHandler(NSException *);

void eHandler(NSException *exception) {
	NSLog(@"%@", exception);
	NSLog(@"%@", [exception callStackSymbols]);
}
#endif

#define AUTO_ACCEPT_CALLS 0

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
	[QBSettings setApplicationID:92];
	[QBSettings setAuthKey:@"wJHdOcQSxXQGWx5"];
	[QBSettings setAuthSecret:@"BTFsj7Rtt27DAmT"];
	
	[SampleCore setUsersDataSource:[[UsersDataSource alloc] init]];
	[SampleCore setPushMessagesManager:[[PushMessagesManager alloc] init]];
	[SampleCore setChatManager:[[ChatManager alloc] init]];
	[SampleCore setSettings:[[Settings alloc] init]];
	[SampleCore setSoundManager:[[QMSoundManager alloc] init]];

	/**
	 *  WEB
	 */
//	[QBSettings setApplicationID:28287];
//	[QBSettings setAuthKey:@"XydaWcf8OO9xhGT"];
//	[QBSettings setAuthSecret:@"JZfqTspCvELAmnW"];

	id<UsersDataSourceProtocol> dataSource = [SampleCore usersDataSource];
#ifdef DEBUG
    NSSetUncaughtExceptionHandler(&eHandler);
#endif
	
	// for UI tests
	// TODO: review
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	if ([arguments containsObject:@"ResetUserDefaults"]) {
		[self destroyUserDefaults];
		
		dataSource.currentUser = nil;
	}
	
	if ([arguments containsObject:@"UserIsLoggedIn"]) {
		
		dataSource.currentUser = dataSource.users.firstObject;
	}
	
	// should NOT be enabled in UI tests
	if (![arguments containsObject:@"TESTS"]) {

#if AUTO_ACCEPT_CALLS == 1
		settings.autoAcceptCalls = YES;
		
		[self destroyUserDefaults];
		
		
		dataSource.currentUser = dataSource.users[1]; // User2
#endif
	}
	
    self.window.backgroundColor = [UIColor whiteColor];
    
    //SVProgressHUD preferences
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setRingThickness:kQBRingThickness];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
   
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:YES];
    }

    [QBSettings setLogLevel:QBLogLevelDebug];
//    [QBRTCConfig setLogLevel:QBRTCLogLevelVerboseWithWebRTC];
	[QBSettings setAutoReconnectEnabled:YES];
    //QuickbloxWebRTC preferences
	
    [QBRTCClient initializeRTC];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCConfig mediaStreamConfiguration].videoCodec = QBRTCVideoCodecH264;
    
	
	[[SampleCoreManager instance] unsubscribeSavedUserFromPushNotificationsIfNeededWithSuccessBlock:nil errorBlock:nil];
	
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
	if (notificationSettings.types != UIUserNotificationTypeNone) {
		NSLog(@"didRegisterUser is called");
		[application registerForRemoteNotifications];
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	if (!deviceToken) {
		NSLog(@"No push token");
		return;
	}
	
	QBUUser *currentUser = [[SampleCore usersDataSource] currentUserWithDefaultPassword];
	
	if (!currentUser) {
		return;
	}
	
	[[SampleCoreManager instance] logInWithUserInREST:currentUser successBlock:^{
		[[SampleCoreManager instance] registerCurrentUserForRemoteNotificationsWithDeviceToken:deviceToken successBlock:^{
			NSLog(@"%@", @"Subscribed to push notifications!");
		} errorBlock:^(QBError *error) {
			[SVProgressHUD showErrorWithStatus:@"Error! Can not subscribe to push notifications" maskType:SVProgressHUDMaskTypeClear];
			NSLog(@"%@ %@", @"Error! Can not subscribe to push notifications:", error.reasons.description);
		}];
	} errorBlock:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Error! Can not subscribe to push notifications" maskType:SVProgressHUDMaskTypeClear];
		NSLog(@"%@ %@", @"Error! Can not subscribe to push notifications:", error.description);
	}];
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[SampleCore chatManager] disconnectIfNeededInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	QBUUser *user = [[SampleCore usersDataSource] currentUserWithDefaultPassword];
	if (user != nil && ![[QBChat instance] isConnected]) {
		[SVProgressHUD showWithStatus:@"Doing chat reconnect..."];
		
		[[SampleCoreManager instance] connectToChatWithUser:user successBlock:^{
			[SVProgressHUD showSuccessWithStatus:@"Chat reconnected"];
		} errorBlock:^(NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Can not reconnect to chat"];
		} chatDisconnectedBlock:nil chatReconnectedBlock:nil];

	}
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"%@", userInfo);
}

#pragma mark Helpers for UI testing

- (void)destroyUserDefaults {
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end


