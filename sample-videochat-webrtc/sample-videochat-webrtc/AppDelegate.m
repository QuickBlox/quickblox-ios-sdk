//
//  AppDelegate.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Settings.h"
#import "Profile.h"

const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;
static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";
static NSUInteger const kErrorDomaimCode = -1000;

//To update the Credentials, please see the README file.
const NSUInteger kApplicationID = 0;
NSString *const kAuthKey        = @"";
NSString *const kAuthSecret     = @"";
NSString *const kAccountKey     = @"";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.isCalling = NO;
    self.window.backgroundColor = [UIColor whiteColor];
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    [QBSettings setAccountKey:kAccountKey];
    
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    [QBRTCClient initializeRTC];
    
    return YES;
}

- (void)setIsCalling:(Boolean)isCalling {
    if (self.isCalling != isCalling) {
        _isCalling = isCalling;
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
            if (self.isCalling == NO) {
                [self disconnect:nil];
            }
        }
    }
}

// MARK: - Application states
- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (![QBChat instance].isConnected) {
        [SVProgressHUD showSuccessWithStatus: @"Connecting..."];
        [self connect:^(NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus: error.localizedDescription];
                return;
            }
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.isCalling == NO) {
        [self disconnect:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
        [self disconnect:nil];
}

//MARK: - Connect/Disconnect
- (void)connect:(nullable QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    
    if (currentUser.isFull == NO) {
        if (completion) {
            completion([NSError errorWithDomain:kChatServiceDomain
                                           code:kErrorDomaimCode
                                       userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Please enter your login and username.", nil)}]);
            
        }
        return;
    }
    
    if (QBChat.instance.isConnected) {
        if (completion) {
            completion(nil);
        }
    } else {
        QBSettings.autoReconnectEnabled = YES;
        [QBChat.instance connectWithUserID:[currentUser ID] password:[currentUser password] completion:completion];
    }
}

- (void)disconnect:(nullable QBChatCompletionBlock)completion {
    [QBChat.instance disconnectWithCompletionBlock:completion];
}

@end
