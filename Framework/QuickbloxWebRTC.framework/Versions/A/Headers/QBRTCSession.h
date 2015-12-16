//
//  QBRTCSession.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 05.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "QBRTCTypes.h"

@class QBRTCVideoTrack;
@class QBRTCMediaStream;

/**
 * Class for storing information about QBWebRTC session, tracks and opponents
 */
@interface QBRTCSession : NSObject

/// Init is not a supported initializer for this class., use [[QBRTCClient instance] createNewSessionWithOpponents:withConferenceType:]
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class., use [[QBRTCClient instance] createNewSessionWithOpponents:withConferenceType:]")));

/// Unique session identifier
@property (strong, nonatomic, readonly) NSString *ID;

/// Initiator ID
@property (strong, nonatomic, readonly) NSNumber *initiatorID;

/// IDs of opponents in current session
@property (strong, nonatomic, readonly) NSArray *opponentsIDs;

/// Conference type QBRTCConferenceTypeAudio - audio conference, QBRTCConferenceTypeVideo - video conference
@property (assign, nonatomic, readonly) QBRTCConferenceType conferenceType;

/// QBRTCMediaStream instance that has both video and audio tracks and allows to manage them
@property (strong, nonatomic, readonly) QBRTCMediaStream *localMediaStream;

/**
 *  Start call. Opponent will receive new session signal in QBRTCClientDelegate method 'didReceiveNewSession:userInfo:
 *  called by startCall: or acceptCall:
 *
 * @param userInfo The user information dictionary for the stat call. May be nil.
 */
- (void)startCall:(NSDictionary *)userInfo;

/**
 * Accept call. Opponent's will receive accept signal in QBRTCClientDelegate method 'session:acceptedByUser:userInfo:'
 *
 * @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)acceptCall:(NSDictionary *)userInfo;

/**
 * Reject call. Opponent's will receive reject signal in QBRTCClientDelegate method 'session:rejectedByUser:userInfo:'
 *
 * @param userInfo The user information dictionary for the reject call. May be nil.
 */
- (void)rejectCall:(NSDictionary *)userInfo;

/**
 * Hang up. Opponent's will receive hung up signal in QBRTCClientDelegate method 'session:hungUpByUser:userInfo:'
 *
 * @param userInfo The user information dictionary for the hang up. May be nil.
 */
- (void)hangUp:(NSDictionary *)userInfo;

/**
 *  Remote track with opponent ID
 *
 *  @param userID ID of opponent
 *
 *  @return QBRTCVideoTrack instance
 */
- (QBRTCVideoTrack *)remoteVideoTrackWithUserID:(NSNumber *)userID;

/**
 *  Connection state for opponent
 *
 *  @param userID ID of opponent
 *
 *  @return QBRTCConnectionState connection state for opponent
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;

@end
