//
//  QBWebRTCConfig.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 13.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRTCConfig : NSObject

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/**
 * Set custom ICE servers
 *
    For example:

    NSURL *stunUrl =
    [NSURL URLWithString:@"stun:stun.l.google.com:19302"];
    
    QBICEServer *stunServer =
    [QBICEServer serverWithURL:stunUrl
                      username:@""
                      password:@""];
 
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
 
    [QBRTCConfig setICEServers:@[stunServer, turnUDPServer, turnTCPServer]];
 *
 * @param iceServers array of QBICEServer instances
 */
+ (void)setICEServers:(NSArray *)iceServers;

/**
 *  Get custom ICE servers
 *
 *  @return array of QBICEServer instances
 */
+ (NSArray *)iceServers;

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
 *  Set dialing time interval
 *  Default value: 5 sec
 *
 *  @param dialingTimeInterval time in sec
 */
+ (void)setDialingTimeInterval:(NSTimeInterval)dialingTimeInterval;

/**
 *  Set anser time interval
 *  Default value: 45 sec
 *
 *  @param answerTimeInterval time interval in sec
 */
+ (void)setAnswerTimeInterval:(NSTimeInterval)answerTimeInterval;

/**
 *  Set max connections in conference
 *
 *  @param maxOpponentsCount max opponents in conference
 */
+ (void)setMaxOpponentsCount:(NSUInteger)maxOpponentsCount;

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
 *  Anser time interval
 *
 *  @return current anser time interval;
 */
+ (NSTimeInterval)answerTimeInterval;

/**
 *  Max connections in conference
 *
 *  @return current value
 */
+ (NSUInteger)maxOpponentsCount;

/**
 * Disconnect time interval
 *
 *  @return current value
 */
+ (NSTimeInterval)disconnectTimeInterval;

@end
