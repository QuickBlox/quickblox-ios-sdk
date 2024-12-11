//
//  QBRTCClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <QuickbloxWebRTC/QBRTCBaseClient.h>

#import <QuickbloxWebRTC/QBRTCClientDelegate.h>
#import <QuickbloxWebRTC/QBRTCTypes.h>

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

NS_ASSUME_NONNULL_END
