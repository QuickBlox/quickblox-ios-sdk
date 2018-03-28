//
//  QBRTCSession.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCBaseSession.h"

@class QBRTCRecorder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCSession class interface.
 *  This class is storing information about rtc session, tracks and opponents.
 *
 *  @see QBRTCBaseSession
 */
@interface QBRTCSession : QBRTCBaseSession

/**
 *  Calls recorder.
 *
 *  @discussion Class instance for calls record. Recording remote video and audio track plus local microphone.
 *
 *  @note Available only for 1 to 1 audio and video calls, nil otherwise. Not available for low performance devices,
 *  such as iPod1,1, iPod2,1, iPod3,1, iPod4,1, iPod5,1, iPhone1,1, iPhone1,2, iPhone2,1, iPhone3,1, iPhone4,1, iPad1,1, 
 *  iPad2,1, iPad2,2, iPad2,3, iPad2,4, iPad2,5, iPad2,6, iPad2,7.
 *  Will become nil if record was finished and finalized AND session was closed.
 *
 *  @see UIDevice+QBPerformance, qbrtc_lowPerformanceDevices
 */
@property (strong, nonatomic, nullable) QBRTCRecorder *recorder;

/**
 *  Unique session identifier.
 */
@property (strong, nonatomic, readonly) NSString *ID;

/**
 *  Session initiator user ID.
 */
@property (strong, nonatomic, readonly) NSNumber *initiatorID;

/**
 *  Current user ID.
 */
@property (assign, nonatomic, readonly) NSNumber *currentUserID;

/**
 *  IDs of opponents in current session.
 */
@property (strong, nonatomic, readonly) NSArray <NSNumber *> *opponentsIDs;

/**
 *  Start call. Opponent will receive new session signal in QBRTCClientDelegate method 'didReceiveNewSession:userInfo:
 *  called by startCall: or acceptCall:
 *
 *  @param userInfo The user information dictionary for the stat call. May be nil.
 */
- (void)startCall:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Accept call. Opponent's will receive accept signal in QBRTCClientDelegate method 'session:acceptedByUser:userInfo:'
 *
 *  @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)acceptCall:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Reject call. Opponent's will receive reject signal in QBRTCClientDelegate method 'session:rejectedByUser:userInfo:'
 *
 *  @param userInfo The user information dictionary for the reject call. May be nil.
 */
- (void)rejectCall:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

/**
 *  Hang up. Opponent's will receive hung up signal in QBRTCClientDelegate method 'session:hungUpByUser:userInfo:'
 *
 *  @param userInfo The user information dictionary for the hang up. May be nil.
 */
- (void)hangUp:(nullable NSDictionary <NSString *, NSString *> *)userInfo;

@end

NS_ASSUME_NONNULL_END
