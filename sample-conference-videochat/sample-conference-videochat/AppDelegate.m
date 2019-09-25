//
//  AppDelegate.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Settings.h"

const NSTimeInterval kQBAnswerTimeInterval = 60.0f;
const NSTimeInterval kQBDialingTimeInterval = 5.0f;

#define ENABLE_STATS_REPORTS 1

//To update the Credentials, please see the README file.
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

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
    
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCConfig setLogLevel:QBRTCLogLevelVerbose];
    
    [QBRTCConfig setConferenceEndpoint:@""];
    NSAssert([QBRTCConfig conferenceEndpoint].length > 0, @"Multi-conference server is available only for Enterprise plans. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts.");
    
#if ENABLE_STATS_REPORTS
    [QBRTCConfig setStatsReportTimeInterval:1.0f];
#endif
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [QBRTCClient initializeRTC];
    
    // loading settings
    [Settings instance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
