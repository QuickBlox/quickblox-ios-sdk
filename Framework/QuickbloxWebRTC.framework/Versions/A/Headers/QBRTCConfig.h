//
//  QBRTCConfig.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class QBRTCMediaStreamConfiguration;
@class QBRTCICEServer;

/// Main class to configure QuickbloxWebRTC settings
@interface QBRTCConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - ICE configuration

/**
 * Set custom ICE servers
 * By default our Quickblox STUN & TURN servers are used
 *
    For example:

    NSString *userName = @"quickblox";
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";

    NSArray *urls = @[
         @"stun:turn.quickblox.com",
         @"turn:turn.quickblox.com:3478?transport=udp",
         @"turn:turn.quickblox.com:3478?transport=tcp"
    ];
 
    QBRTCICEServer *server = [QBRTCICEServer serverWithURLs:urls username:userName password:password];
    [QBRTCConfig setICEServers:@[server]];
 *
 * @param iceServers array of QBRTCICEServer instances
 */
+ (void)setICEServers:(NSArray <QBRTCICEServer *>*)iceServers;

/**
 *  Get custom ICE servers
 *
 *  @return array of QBRTCICEServer instances
 */
+ (NSArray <QBRTCICEServer *> *)iceServers;

#pragma mark - Time interval

/**
 *  Set dialing time interval
 *
 *  Indicates how often we send notifications to your opponents about your call
 *
 *  Default value: 5 seconds
 *  Minimum value: 3 seconds
 *  @param dialingTimeInterval time in seconds
 */
+ (void)setDialingTimeInterval:(NSTimeInterval)dialingTimeInterval;

/**
 *  Set answer time interval
 *
 *  If an opponent did not answer you within dialing time interval, then
 *  userDidNotRespond: and then connectionClosedForUser: delegate methods will be called
 *
 *  Default value: 45 seconds
 *  Minimum value: 10 seconds
 *  @param answerTimeInterval time interval in seconds
 */
+ (void)setAnswerTimeInterval:(NSTimeInterval)answerTimeInterval;

/**
 *  Set disconnect time interval
 *
 *  After a disconnect from an opponent happend we are starting timer and waiting for a given time interval
 *  in case connection establishing/reconnecting again
 *
 *  Default value: 30 seconds, cannot be lower than 10
 *  @param disconnectTimeInterval time interval in seconds
 *
 *  @warning *Deprecated in 2.3.* No longer in use due to updated webrtc specification.
 */
+ (void)setDisconnectTimeInterval:(NSTimeInterval)disconnectTimeInterval DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. No longer in use due to updated webrtc specification.");

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
 *
 *  @warning *Deprecated in 2.3.* No longer in use due to updated webrtc specification.
 */
+ (NSTimeInterval)disconnectTimeInterval DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. No longer in use due to updated webrtc specification.");

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

/**
 *  Set Stats report time interval. Default 0 which means you never receive stats
 *
 *  @note low time interval affects on CPU performance
 *  @param timeInterval time interval in seconds
 */
+ (void)setStatsReportTimeInterval:(NSTimeInterval)timeInterval;

/**
 *  Current stats report time interval
 *
 *  @return current value
 */
+ (NSTimeInterval)statsReportTimeInterval;

/**
 * Set QuickbloxWebRTC SDK log level (by default: QBRTCLogLevelDebug).
 *
 * Possible values:
 * QBRTCLogLevelNothing:			Nothing in Log
 * QBRTCLogLevelErrors:				Can see Errors
 * QBRTCLogLevelWarnings:			Can see Warnings
 * QBRTCLogLevelInfo:				Some Information Logs
 * QBRTCLogLevelVerbose:			Full QuickbloxWebRTC Log
 * QBRTCLogLevelVerboseWithWebRTC:	Full QuickbloxWebRTC and WebRTC native Log
 *
 *
 * @param logLevel New log level
 */
+ (void)setLogLevel:(QBRTCLogLevel)logLevel;

/**
 *  Get QuickbloxWebRTC SDK log level (by default: QBRTCLogLevelDebug).
 *
 *  @return QBRTCLogLevel current log level
 */
+ (QBRTCLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
