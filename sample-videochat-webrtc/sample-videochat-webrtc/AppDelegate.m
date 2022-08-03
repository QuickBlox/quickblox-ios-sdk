//
//  AppDelegate.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "Profile.h"
#import "UIColor+Videochat.h"

const NSTimeInterval kQBAnswerTimeInterval = 30.0f;
const NSTimeInterval kQBDialingTimeInterval = 5.0f;
static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";

//To update the Credentials, please see the README file.
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    QBSettings.applicationID = kApplicationID;
    QBSettings.authKey = kAuthKey;
    QBSettings.authSecret = kAuthSecret;
    QBSettings.accountKey = kAccountKey;
    
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    UINavigationController *root =
    [storyboard instantiateViewControllerWithIdentifier:@"AuthNavVC"];
    root.view.backgroundColor = UIColor.blueBarColor;
    
    Profile *profile = [[Profile alloc] init];
    BOOL isLoggedIn = profile.isFull;
    if (isLoggedIn) {
        storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        UIViewController *users =
        [storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
        NSMutableArray<UIViewController *>*viewControllers = root.viewControllers.mutableCopy;
        [viewControllers addObject:users];
        [root setViewControllers:viewControllers animated:NO];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
