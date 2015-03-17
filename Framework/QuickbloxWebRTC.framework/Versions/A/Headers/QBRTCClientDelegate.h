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
 *  Called in case when started new session with you
 *
 *  @param session QBWebRTCSession instance
 */
- (void)didReceiveNewSession:(QBRTCSession *)session;

/**
 * Called in case when you are calling to user, but he hasn't answered
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session userDoesNotRespond:(NSNumber *)userID;

/**
 * Called in case when opponent has rejected you call
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Called in case when opponent hung up
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID;

/**
 *  Called in case when receive local video track
 *
 *  @param videoTrack
 */
- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack;

/**
 *  Called in case when receive remote video track from opponent
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of opponent
 */
- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called in case when connection state changed
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called in case when connection initiated
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session startConnectionToUser:(NSNumber *)userID;

/**
 *  Called in case when connection is established with opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called in case when disconnected from opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID;

/**
 *  Called in case when disconnected by timeout
 *
 *  @param session QBRTCSession instance
 *  @param userID  QBRTCSession instance
 */
- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID;

/**
 *  Called in case when connection failed with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectionFailedWithUser:(NSNumber *)userID;

/**
 *  Called in case when session did close
 *
 *  @param session QBRTCSession instance
 */

- (void)sessionDidClose:(QBRTCSession *)session;

/**
 *  Called in case when session will close
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionWillClose:(QBRTCSession *)session;


- (void)session:(QBRTCSession *)session setAudioCategoryError:(NSError *)error;

@end
