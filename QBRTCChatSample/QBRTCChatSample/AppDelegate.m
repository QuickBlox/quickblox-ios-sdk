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
const NSTimeInterval kQBAnswerTimeInterval = 25.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 15.f;

const NSUInteger kQBApplicationID = 92;
NSString *const kQBRegisterServiceKey = @"wJHdOcQSxXQGWx5";
NSString *const kQBRegisterServiceSecret = @"BTFsj7Rtt27DAmT";
NSString *const kQBAccountKey = @"7yvNe17TnjNUqDoPwfqp";

@implementation AppDelegate

- (NSArray *)iceServers {
    
    NSURL *stunUrl =
    [NSURL URLWithString:@"stun:stun.l.google.com:19302"];
    
    QBICEServer* stunServer =
    [QBICEServer serverWithURL:stunUrl
                      username:@""
                      password:@""];
#if QB_DEFAULT_ICE_SERVERS
    NSURL *turnUDPUrl =
    [NSURL URLWithString:@"turn:turnserver.quickblox.com:3478?transport=udp"];
    QBICEServer *turnUDPServer =
    [QBICEServer serverWithURL:turnUDPUrl
                       username:@"user"
                       password:@"user"];
    NSURL *turnTCPUrl =
    [NSURL URLWithString:@"turn:turnserver.quickblox.com:3478?transport=tcp"];
    
    RTCICEServer* turnTCPServer =
    [QBICEServer serverWithURL:turnTCPUrl
                       username:@"user"
                       password:@"user"];
#else
    NSURL *turnUDPUrl =
    [NSURL URLWithString:@"turn:turn2.xirsys.com:443?transport=udp"];
    
    QBICEServer* turnUDPServer =
    [QBICEServer serverWithURL:turnUDPUrl
                      username:@"36b7fdaf-524e-4c38-a6d3-b174166fd573"
                      password:@"0371abb5-fa95-4bbe-b282-25e5888513f7"];
    NSURL *turnTCPUrl =
    [NSURL URLWithString:@"turn:turn2.xirsys.com:443?transport=tcp"];
    QBICEServer* turnTCPServer =
    [QBICEServer serverWithURL:turnTCPUrl
                      username:@"36b7fdaf-524e-4c38-a6d3-b174166fd573"
                      password:@"0371abb5-fa95-4bbe-b282-25e5888513f7"];
#endif
    
    return @[stunServer, turnTCPServer, turnUDPServer];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Quickblox preferences
    [QBApplication sharedApplication].applicationId = kQBApplicationID;
    [QBConnection registerServiceKey:kQBRegisterServiceKey];
    [QBConnection registerServiceSecret:kQBRegisterServiceSecret];
    [QBSettings setAccountKey:kQBAccountKey];
    [QBSettings setLogLevel:QBLogLevelNothing];
    
    //QuickbloxWebRTC preferences
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
    [QBRTCConfig setICEServers:self.iceServers];
    
    //SVProgressHUD preferences
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setRingThickness:kQBRingThickness];
    
    return YES;
}

@end
