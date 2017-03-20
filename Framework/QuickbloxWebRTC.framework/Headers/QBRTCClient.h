//
//  QBRTCClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCBaseClient.h"

#import "QBRTCClientDelegate.h"
#import "QBRTCTypes.h"

@class QBRTCSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCClient class interface.
 *  Represents client to initialize call session and notify about call's state.
 */
@interface QBRTCClient : QBRTCBaseClient

/**
 *  QBRTCClient shared instance.
 *
 *  @return QBRTCClient instance
 */
+ (instancetype)instance;

/**
 *  Initialize RTCClient signaling in order to receive and send calls.
 *
 *  @note You should call this method before any interaction with QuickbloxWebRTC.
 */
+ (void)initializeRTC;

/**
 *  Add delegate to the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCClientDelegate protocol
 *
 *  @see QBRTCClientDelegate
 */
- (void)addDelegate:(id<QBRTCClientDelegate>)delegate;

/**
 *  Remove delegate from the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCClientDelegate protocol
 *
 *  @see QBRTCClientDelegate
 */
- (void)removeDelegate:(id<QBRTCClientDelegate>)delegate;

/**
 *  Create new session
 *
 *  @param opponents        opponents IDs, array of NSNumber instances
 *  @param conferenceType   Type of conference. 'QBRTCConferenceTypeAudio' and 'QBRTCConferenceTypeVideo' values are available
 *
 *  @return New QBRTCSession instance
 */
- (QBRTCSession *)createNewSessionWithOpponents:(NSArray <NSNumber *> *)opponents
                             withConferenceType:(QBRTCConferenceType)conferenceType;

@end

@interface QBRTCClient (Deprecated)

/**
 *  Deinitialize QuickbloxWebRTC
 *  Disables SSL subsystem and signaling
 *
 *  Call this method when you finish your work with QuickbloxWebRTC
 *
 *  @warning *Deprecated in 2.5*. From now on QBRTCCLient managing deinitialization of webrtc on itself. Just remove usage of this method.
 */
+ (void)deinitializeRTC DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. From now on QBRTCCLient managing deinitialization of webrtc on itself. Just remove usage of this method.");

@end

NS_ASSUME_NONNULL_END
