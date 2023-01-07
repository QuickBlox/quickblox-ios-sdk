//
//  AppDelegate.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "PresenterViewController.h"

const NSTimeInterval kQBAnswerTimeInterval = 30.0f;
const NSTimeInterval kQBDialingTimeInterval = 5.0f;
static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [Quickblox initWithApplicationId:0
                             authKey:@""
                          authSecret:@""
                          accountKey:@""
    ];
    
    QBSettings.logLevel = QBLogLevelNothing;
    [QBSettings disableFileLogging];
    [QBSettings disableXMPPLogging];
    
    QBRTCConfig.answerTimeInterval = kQBAnswerTimeInterval;
    QBRTCConfig.dialingTimeInterval = kQBDialingTimeInterval;
    QBRTCConfig.statsReportTimeInterval = 3.0f;
    
    [QBRTCClient initializeRTC];
    
    Settings *settings = [[Settings alloc] init];
    settings.mediaConfiguration.videoCodec = QBRTCVideoCodecVP8;
    [settings saveToDisk];
    [settings applyConfig];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[PresenterViewController alloc] init];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
