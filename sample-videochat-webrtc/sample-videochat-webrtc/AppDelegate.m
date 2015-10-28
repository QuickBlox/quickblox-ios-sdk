//
//  AppDelegate.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"

#define QB_DEFAULT_ICE_SERVERS 0

const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 30.f;

const NSUInteger kApplicationID = 92;
NSString *const kAuthKey        = @"wJHdOcQSxXQGWx5";
NSString *const kAuthSecret     = @"BTFsj7Rtt27DAmT";
NSString *const kAcconuntKey    = @"7yvNe17TnjNUqDoPwfqp";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Quickblox preferences
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    //QuickbloxWebRTC preferences
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
    [QBRTCConfig setDialingTimeInterval:5];
    
    //SVProgressHUD preferences
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setRingThickness:kQBRingThickness];
    
    return YES;
}

@end
