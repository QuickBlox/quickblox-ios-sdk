//
//  QBRTCConfig.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 13.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

@class QBRTCMediaStreamConfiguration;

/// Main class to configure QuickbloxWebRTC settings
@interface QBRTCConfig : NSObject

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

#pragma mark - ICE configuration

/**
 * Set custom ICE servers
 *
    For example:

    NSURL *stunUrl = [NSURL URLWithString:@"stun:turn.quickblox.com"];
    QBRTCICEServer *stunServer = [QBRTCICEServer serverWithURL:stunUrl username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
 
    NSURL *turnUDPUrl = [NSURL URLWithString:@"turn:turn.quickblox.com:3478?transport=udp"];
    QBRTCICEServer *turnUDPServer = [QBRTCICEServer serverWithURL:turnUDPUrl username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
 
    NSURL *turnTCPUrl = [NSURL URLWithString:@"turn:turn.quickblox.com:3478?transport=tcp"];
    QBRTCICEServer* turnTCPServer = [QBRTCICEServer serverWithURL:turnTCPUrl username:@"quickblox" password:@"baccb97ba2d92d71e26eb9886da5f1e0"];
 
    [QBRTCConfig setICEServers:@[stunServer, turnUDPServer, turnTCPServer]];
 *
 * @param iceServers array of QBRTCICEServer instances
 */
+ (void)setICEServers:(NSArray *)iceServers;

/**
 *  Get custom ICE servers
 *
 *  @return array of QBRTCICEServer instances
 */
+ (NSArray *)iceServers;

#pragma mark - Time interval

/**
 *  Set dialing time interval
 *  Default value: 5 sec
 *
 *  @param dialingTimeInterval time in sec
 */
+ (void)setDialingTimeInterval:(NSTimeInterval)dialingTimeInterval;

/**
 *  Set answer time interval
 *  Default value: 45 sec
 *  Minimal value: 10 sec
 *  @param answerTimeInterval time interval in sec
 */
+ (void)setAnswerTimeInterval:(NSTimeInterval)answerTimeInterval;

/**
 *  Set disconnect time interval
 *
 *  Default value: 30 sec
 *  @param disconnectTimeInterval time interval in sec
 */
+ (void)setDisconnectTimeInterval:(NSTimeInterval)disconnectTimeInterval;

/**
 *  Dialing time interval
 *
 *  @return current dialing time interval
 */
+ (NSTimeInterval)dialingTimeInterval;

/**
 *  Answer time interval
 *
 *  @return current answer time interval;
 */
+ (NSTimeInterval)answerTimeInterval;

/**
 * Disconnect time interval
 *
 *  @return current value
 */
+ (NSTimeInterval)disconnectTimeInterval;

#pragma mark - Media stream configuration

#pragma mark Datagram Transport Layer Security

/**
 *  Enable / Disable Datagram Transport Layer Security
 *
 *  @param enabled YES/NO (default YES)
 */
+ (void)setDTLSEnabled:(BOOL)enabled;

/**
 *  Datagram Transport Layer Security state
 *
 *  @return current value (default YES)
 */
+ (BOOL)DTLSEnabled;

/**
 *  Setter for media stream configuration
 *
 *  @param configuration QBRTCMediaStreamConfiguration configuration
 */
+ (void)setMediaStreamConfiguration:(QBRTCMediaStreamConfiguration *)configuration;

/**
 *  Media stream configuration
 *  by default it is [QBRTCMediaStreamConfiguration defaultConfiguration]
 *
 *  @return QBRTCMediaStreamConfiguration instance
 */
+ (QBRTCMediaStreamConfiguration *)mediaStreamConfiguration;

@end
