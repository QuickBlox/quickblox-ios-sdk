//
//  QBRTCClient.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 01.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@class QBRTCSession;

@protocol QBRTCClientDelegate;

/**
 Client to initialize call session and notify about call's state
 */
@interface QBRTCClient : NSObject

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/**
 * Initialize QuickbloxWebRTC and configure signaling
 * Enables SSL subsystem and signaling
 *
 * You should call this method before any interact with QuickbloxWebRTC
 */
+ (void)initializeRTC;

/**
 * Deinitialize QuickbloxWebRTC
 * Disables SSL subsystem and signaling
 *
 * Call this method when you finish your work with QuickbloxWebRTC
 */
+ (void)deinitializeRTC;

/**
 *  QBRTCClient shared instance
 *
 *  @return QBRTCClient instance
 */
+ (instancetype)instance;

/// Add delegate to observers list
- (void)addDelegate:(id<QBRTCClientDelegate>)delegate;

/// Remove delegate from observers list
- (void)removeDelegate:(id<QBRTCClientDelegate>)delegate;

/**
 *  Create new session
 *
 *  @param opponents        opponents IDs, array of NSNumber instances
 *  @param conferenceType   Type of conference. 'QBRTCConferenceTypeAudio' and 'QBRTCConferenceTypeVideo' values are available
 *
 *  @return New QBRTCSession instance
 */
- (QBRTCSession *)createNewSessionWithOpponents:(NSArray *)opponents withConferenceType:(QBRTCConferenceType)conferenceType;

@end
