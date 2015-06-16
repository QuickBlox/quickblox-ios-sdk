//
//  QBRTCClientDelegate.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 12.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

@class QBRTCSession;
@class QBRTCVideoTrack;

@protocol QBRTCClientDelegate <NSObject>
@optional

/**
 *  Called when started new session with you
 *
 *  @param session  QBWebRTCSession instance
 *  @param userInfo The user information dictionary for the new session. May be nil.
 */
- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo;

/**
 * Called when you called to user, but user does not respond
 * use +[QBRTCConfig setAnswerTimeInterval:value] to set answer time interval
 * default value: 45 seconds
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session userDoesNotRespond:(NSNumber *)userID;

/**
 * Called in case when opponent has rejected you call
 *
 * @param userID ID of opponent
 * @param userInfo The user information dictionary for the reject call. May be nil.
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 * Called in case when opponent has accept you call
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session acceptByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Called when opponent hung up
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 *  @param userInfo The user information dictionary for the hung up. May be nil.
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Called when received local video track
 *
 *  @param videoTrack
 */
- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack;

/**
 *  Called when received remote video track from opponent
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of opponent
 */
- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called when connection state changed
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called when connection initiated
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session startConnectionToUser:(NSNumber *)userID;

/**
 *  Called when connection is established with opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called when disconnected from opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
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
- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID;

/**
 *  Called when connection failed with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectionFailedWithUser:(NSNumber *)userID;

/**
 *  Called when session is closed
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionDidClose:(QBRTCSession *)session;

/**
 *  Called when session will close
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionWillClose:(QBRTCSession *)session;

@end
