//
//  QBRTCClientDelegate.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

@class QBRTCSession;

@protocol QBRTCBaseClientDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCClientDelegate protocol.
 *
 *  @note all delegate methods will be called on main thread due to webrtc restrictions
 */
@protocol QBRTCClientDelegate <QBRTCBaseClientDelegate>

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
 *  Called when session is closed.
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionDidClose:(QBRTCSession *)session;

@end

NS_ASSUME_NONNULL_END
