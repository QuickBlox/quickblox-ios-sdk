//
//  QBRTCClientDelegate.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 12.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

@class QBRTCSession;
@class QBRTCVideoTrack;
@class QBRTCMediaStream;
@class QBRTCStatsReport;

/**
 * QBRTCClientDelegate protocol
 *
 * NOTE: all delegate methods will be called on main thread due to webrtc restrictions
 */
@protocol QBRTCClientDelegate <NSObject>
@optional

/**
 *  Called when someone started a new session with you
 *
 *  @param session  QBRTCSession instance
 *  @param userInfo The user information dictionary for the new session. May be nil.
 */
- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo;

/**
 *  Called when local media stream successfully initialized itself and configured tracks
 *	called after startCall: or accept: methods
 *
 *  After initializing you are able to set a video capture
 *
 *  @param session     QBRTCSession instance
 *  @param mediaStream QBRTCMediaStream instance
 */
- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream;

/**
 *  Called by timeout with updated stats report for user ID
 *
 *  Configure time interval with [QBRTCConfig setStatsReportTimeInterval:timeInterval]
 *
 *  @param session QBRTCSession instance
 *  @param report  QBRTCStatsReport instance
 *  @param userID  user ID
 */
- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID;

/**
 * Called in case when user did not respond to your call within timeout
 * use +[QBRTCConfig setAnswerTimeInterval:value] to set answer time interval
 * default value: 45 seconds
 * @param userID ID of user
 */
- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID;

/**
 * Called in case when user rejected you call
 *
 * @param userID ID of user
 * @param userInfo The user information dictionary for the reject call. May be nil.
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 * Called in case when user accepted your call
 *
 * @param userID ID of user
 */
- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Called when user hung up
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 *  @param userInfo The user information dictionary for the hung up. May be nil.
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Called when received remote video track from user
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of user
 */
- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called when connection is closed for user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called when connection is initiated with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session startedConnectingToUser:(NSNumber *)userID;

/**
 *  Called when connection is established with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called when disconnected from user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID;

/**
 *  Called when disconnected by timeout
 *  use [QBRTCConfig setDisconnectTimeInterval:value] to set disconnect time interval
 *  default value: 35 seconds
 *  after you disconnected from all users, session will close
 *  @param session QBRTCSession instance
 *  @param userID  QBRTCSession instance
 */
- (void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID;

/**
 *  Called when connection failed with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID;

/**
 *  Called when session is closed
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionDidClose:(QBRTCSession *)session;

@end
