//
//  QBRTCSession.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 05.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@class QBPeerChannel;

@interface QBRTCSession : NSObject

/**
 *  Enable/Disable audio stream
 */
@property (assign, nonatomic) BOOL audioEnabled;

/**
 * Enalbe/Disable video stream
 */
@property (assign, nonatomic) BOOL videoEnabled;

/**
 *  Unique session identifier
 */
@property (strong, nonatomic, readonly) NSString *ID;

/**
 *  Caller ID
 */
@property (strong, nonatomic, readonly) NSNumber *callerID;

/**
 *  IDs of opponents in current session
 */
@property (strong, nonatomic, readonly) NSArray *opponents;

/**
 *  Conferenct type QBConferenceTypeAudio - audio conference, QBConferenceTypeVideo - video conference
 */
@property (assign, nonatomic, readonly) QBConferenceType conferenceType;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/**
 *  Start call
 */
- (void)startCall:(NSDictionary *)userInfo;

/**
 * Accept call with userInfo.
 *
 * @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)acceptCall:(NSDictionary *)userInfo;

/**
 * Reject call. Opponent will receive reject signal in QBChatDelegate's method 'callDidRejectByUser:'
 *
 * @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)rejectCall:(NSDictionary *)userInfo;

/**
 * HangUp
 *
 * @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)hangUp:(NSDictionary *)userInfo;

/**
 *  Add user to current session
 *
 *  @param userID   ID of opponent
 *  @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (BOOL)addUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo;

/**
 *  Switch Front / Back video input. (Default: Front camera)
 *
 *  @param block isFrontCamera YES/NO
 */
- (void)switchCameraPosition:(void (^)(BOOL isFrontCamera))block;

/**
 * Switch audio output. (Defaults: ipad - speaker, iphone - headphone )
 *
 * @param block isSpeaker YES/NO
 */
- (void)switchAudioOutput:(void (^)(BOOL isSpeaker))block;

/**
 * Connection state for opponent
 *
 * @param userID ID of opponent
 *
 * @return QBRTCConnectionState
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;

@end
