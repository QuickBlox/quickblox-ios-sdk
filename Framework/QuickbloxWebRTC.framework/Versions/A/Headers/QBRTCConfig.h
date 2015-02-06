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

+ (void)setICEServers:(NSArray *)iceServers;

+ (NSArray *)iceServers;

/**
 *  Set dialing time interval
 *  Default value 5 sec
 *
 *  @param dialingTimeInterval time in sec
 */
+ (void)setDialingTimeInterval:(NSTimeInterval)dialingTimeInterval;

/**
 *  Set anser time interval
 *  Default value 45 sec
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

#pragma mark - Private API

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

@end
