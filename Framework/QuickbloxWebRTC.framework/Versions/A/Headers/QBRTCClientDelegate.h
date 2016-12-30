//
//  QBRTCClientDelegate.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

@class QBRTCSession;
@class QBRTCVideoTrack;
@class QBRTCMediaStream;
@class QBRTCStatsReport;
@class QBRTCAudioTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCClientDelegate protocol.
 *
 *  @note all delegate methods will be called on main thread due to webrtc restrictions
 */
@protocol QBRTCClientDelegate <NSObject>

/**
 *  Protocol methods down below are optional and not required to be implemented.
 */
@optional

/**
 *  Called when someone started a new session with you.
 *
 *  @param session  QBRTCSession instance
 *  @param userInfo The user information dictionary for the new session. May be nil.
 */
- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Called when session state has been changed.
 *
 *  @param session QBRTCSession instance
 *  @param state session state
 *
 *  @discussion Use this to track a session state. As SDK 2.3 introduced states for session, you can now manage your own states based on this.
 */
- (void)session:(QBRTCSession *)session didChangeState:(QBRTCSessionState)state;

/**
 *  Called when local media stream successfully initialized itself and configured tracks
 *	called after startCall: or accept: methods.
 *
 *  After initializing you are able to set a video capture
 *
 *  @param session     QBRTCSession instance
 *  @param mediaStream QBRTCMediaStream instance
 *
 *  @warning *Deprecated in 2.3.* Local media stream is initialized with session initialization and can now be configured from the beginning without need of waiting for this delegate.
 */
- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Local media stream is initialized with session initialization and can now be configured from the beginning without need of waiting for this delegate.");

/**
 *  Called by timeout with updated stats report for user ID.
 *
 *  @param session QBRTCSession instance
 *  @param report  QBRTCStatsReport instance
 *  @param userID  user ID
 *
 *  @remark Configure time interval with [QBRTCConfig setStatsReportTimeInterval:timeInterval].
 */
- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID;

/**
 *  Called in case when user did not respond to your call within timeout.
 *
 *  @param userID ID of user
 *
 *  @remark use +[QBRTCConfig setAnswerTimeInterval:value] to set answer time interval
 *  default value: 45 seconds
 */
- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID;

/**
 *  Called in case when user rejected you call.
 *
 *  @param userID ID of user
 *  @param userInfo The user information dictionary for the reject call. May be nil
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Called in case when user accepted your call.
 *
 *  @param userID ID of user
 */
- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Called when user hung up.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 *  @param userInfo The user information dictionary for the hung up. May be nil.
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Called when received remote audio track from user.
 *
 *  @param audioTrack QBRTCAudioTrack instance
 *  @param userID     ID of user
 */
- (void)session:(QBRTCSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID;

/**
 *  Called when received remote video track from user.
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of user
 */
- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called when connection is closed for user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called when connection is initiated with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session startedConnectingToUser:(NSNumber *)userID;

/**
 *  Called when connection is established with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called when disconnected from user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID;

/**
 *  Called when disconnected by timeout.
 *
 *  @param session QBRTCSession instance
 *  @param userID  QBRTCSession instance
 *
 *  @note after you disconnected from all users, session will close
 *
 *  @remark use [QBRTCConfig setDisconnectTimeInterval:] to set disconnect time interval
 *  default value: 30 seconds, cannot be lower than 10
 *
 *  @warning *Deprecated in 2.3.* No longer in use due to updated webrtc specification.
 */
- (void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. No longer in use due to updated webrtc specification.");

/**
 *  Called when connection failed with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID;

/**
 *  Called when session connection state changed for a specific user.
 *
 *  @param session QBRTCSession instance
 *  @param state   state - @see QBRTCConnectionState
 *  @param userID  ID of user
 */
- (void)session:(QBRTCSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID;

/**
 *  Called when session is closed.
 * 
 *  @param session QBRTCSession instance
 */
- (void)sessionDidClose:(QBRTCSession *)session;

@end

NS_ASSUME_NONNULL_END
