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
@class QBRTCVideoTrack;

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
 *  Indicating the physical position of an AVCaptureDevice's hardware on the system.
 */
@property (assign, nonatomic, readonly) AVCaptureDevicePosition currentCaptureDevicePosition;

/**
 * Set audio session category options
 */
@property (assign, nonatomic) AVAudioSessionCategoryOptions audioCategoryOptions;
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
 *  Conference type QBConferenceTypeAudio - audio conference, QBConferenceTypeVideo - video conference
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
 * Hang up
 *
 * @param userInfo The user information dictionary for the accept call. May be nil.
 */
- (void)hangUp:(NSDictionary *)userInfo;

/**
 *  Switch Front / Back video input. (Default: Front camera)
 *
 *  @param block isFrontCamera YES/NO
 */
- (void)switchCamera:(void (^)(BOOL isFrontCamera))block;

/**
 * Switch audio output. (Defaults: ipad - speaker, iphone - headphone )
 *
 * @param block isSpeaker YES/NO
 */
- (void)switchAudioOutput:(void (^)(BOOL isSpeaker))block __attribute__((deprecated("use '+[QBRTCSession seAudioCategoryOptions:'.")));

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
 *  @return ID of opponent
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;

@end
