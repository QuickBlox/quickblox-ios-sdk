//
//  QBRTCBaseClientDelegate.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

@class QBRTCBaseSession;
@class QBRTCStatsReport;
@class QBRTCAudioTrack;
@class QBRTCVideoTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Base client protocol.
 */
@protocol QBRTCBaseClientDelegate <NSObject>

/**
 *  Protocol methods down below are optional and not required to be implemented.
 */
@optional

/**
 *  Called by timeout with updated stats report for user ID.
 *
 *  @param session QBRTCSession instance
 *  @param report  QBRTCStatsReport instance
 *  @param userID  user ID
 *
 *  @remark Configure time interval with [QBRTCConfig setStatsReportTimeInterval:timeInterval].
 */
- (void)session:(__kindof QBRTCBaseSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID;

/**
 *  Called when session state has been changed.
 *
 *  @param session QBRTCSession instance
 *  @param state session state
 *
 *  @discussion Use this to track a session state. As SDK 2.3 introduced states for session, you can now manage your own states based on this.
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeState:(QBRTCSessionState)state;

/**
 *  Called when received remote audio track from user.
 *
 *  @param audioTrack QBRTCAudioTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID;

/**
 *  Called when received remote video track from user.
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called when connection is closed for user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called when connection is initiated with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID;

/**
 *  Called when connection is established with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called when disconnected from user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session disconnectedFromUser:(NSNumber *)userID;

/**
 *  Called when connection failed with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionFailedForUser:(NSNumber *)userID;

/**
 *  Called when session connection state changed for a specific user.
 *
 *  @param session QBRTCSession instance
 *  @param state   state - @see QBRTCConnectionState
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
