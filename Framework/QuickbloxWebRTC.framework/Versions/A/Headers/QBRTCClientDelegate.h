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
- (void)didReceiveNewCallWithSession:(QBRTCSession *)session;

/**
 *  Called in case when opponent is calling to you
 *
 *  @param session QBRTCSession instance
 */
- (void)didReceiveDialingFromSession:(QBRTCSession *)session;

/**
 * Called in case when you are calling to user, but hi hasn't answered
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session userDidNotAnswer:(NSNumber *)userID;

/**
 * Called in case when opponent has rejected you call
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session didRejectByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

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
 *  Called in case when begin connection to opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session startConnectToUser:(NSNumber *)userID;

/**
 *  Called in case when connection with opponent is established
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called in case when opponet disconnected
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session userDisconnected:(NSNumber *)userID;

/**
 *  Called in case when opponent hang up
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session userHangUp:(NSNumber *)userID;

/**
 *  Called in case when session Ended
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionEnded:(QBRTCSession *)session;

@end
