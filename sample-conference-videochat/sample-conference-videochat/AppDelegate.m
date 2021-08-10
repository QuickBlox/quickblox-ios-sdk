//
//  AppDelegate.m
//  sample-conference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Settings.h"
#import <Quickblox/Quickblox.h>
#import "Log.h"
#import "ChatManager.h"
#import "PresenterViewController.h"
#import "Profile.h"

const NSTimeInterval answerTimeInterval = 30.0f;
const NSTimeInterval dialingTimeInterval = 5.0f;

#define ENABLE_STATS_REPORTS 1

//To update the Credentials, please see the README file.
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window.backgroundColor = [UIColor whiteColor];
    
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    QBSettings.autoReconnectEnabled = YES;
    
    [QBRTCConfig setAnswerTimeInterval:answerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:dialingTimeInterval];
    [QBRTCConfig setLogLevel:QBRTCLogLevelVerbose];
    
    [QBRTCConfig setConferenceEndpoint:@""];
    NSAssert([QBRTCConfig conferenceEndpoint].length > 0, @"Multi-conference server is available only for Enterprise plans. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts.");
    
#if ENABLE_STATS_REPORTS
    [QBRTCConfig setStatsReportTimeInterval:1.0f];
#endif
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [QBRTCClient initializeRTC];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[PresenterViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    NSData *lastToken = [userDefaults objectForKey:kToken];
    if ([lastToken isEqualToData:deviceToken]) {
        return;
    }
    
    [userDefaults setObject:deviceToken forKey:kToken];
    [userDefaults setBool:YES forKey:kNeedUpdateToken];
    
    if ([ChatManager.instance tokenHasExpired]) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf createSubscriptionWithToken:deviceToken];
    }];   
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // failed to register push
    Log(@"Push failed to register with error: %@", error);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    application.applicationIconBadgeNumber = 0;
    
    // Logout from chat
    [ChatManager.instance disconnect:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Login to QuickBlox Chat
    [ChatManager.instance connect:nil];
}

- (void)createSubscriptionWithToken:(NSData *)token {
    NSString *deviceUUID = UIDevice.currentDevice.identifierForVendor.UUIDString;
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceUUID;
    subscription.deviceToken = token;

    [QBRequest createSubscription:subscription
                     successBlock:^(QBResponse *response, NSArray *objects) {
        QBMSubscription *newSubscription = nil;
        for (QBMSubscription *subscription in objects) {
            if (subscription.notificationChannel == QBMNotificationChannelAPNS &&
                [subscription.deviceUDID isEqualToString:deviceUUID]) {
                newSubscription = subscription;
            }
        }
        
        [NSUserDefaults.standardUserDefaults setObject:@(newSubscription.ID) forKey:kSubscriptionID];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:kNeedUpdateToken];
        Log(@"[%@] Create Subscription request - Success",  NSStringFromClass(AppDelegate.class));
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Create Subscription request - Error",  NSStringFromClass(AppDelegate.class));
    }];
}

- (void)deleteLastSubscriptionWithCompletion:(void(^)(void))completion {
    NSNumber *lastSubscriptionId = [NSUserDefaults.standardUserDefaults objectForKey:kSubscriptionID];
    if (lastSubscriptionId == nil) {
        if (completion) { completion(); }
        return;
    }
    
    [QBRequest deleteSubscriptionWithID:lastSubscriptionId.unsignedIntValue
                           successBlock:^(QBResponse * _Nonnull response) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kSubscriptionID];
        Log(@"[%@] Delete Subscription request - Success",  NSStringFromClass(AppDelegate.class));
        if (completion) { completion(); }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Delete Subscription request - Error",  NSStringFromClass(AppDelegate.class));
        if (completion) { completion(); }
    }];
}

@end
