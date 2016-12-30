//
//  QBRTCClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@class QBRTCSession;

@protocol QBRTCClientDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Client to initialize call session and notify about call's state
 */
@interface QBRTCClient : NSObject

- (instancetype)init NS_UNAVAILABLE;

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
- (QBRTCSession *)createNewSessionWithOpponents:(NSArray <NSNumber *>*)opponents
                             withConferenceType:(QBRTCConferenceType)conferenceType;

@end

NS_ASSUME_NONNULL_END
