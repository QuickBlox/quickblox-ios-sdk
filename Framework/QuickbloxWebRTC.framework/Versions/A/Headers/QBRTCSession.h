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

@interface QBRTCSession : NSObject

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
 *  Start call. Opponent will receive new session signal in QBRTCClientDelegate method 'didReceiveNewSession:userInfo:
 *
 * @param userInfo The user information dictionary for the stat call. May be nil.
 */
- (void)startCall:(NSDictionary *)userInfo;

/**
 * Accept call. Opponent's will receive accept signal in QBRTCClientDelegate method 'session:acceptByUser:userInfo:'
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
 *  @return ID of opponent
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;

/**
 *  Enable/Disable audio stream
 */
@property (assign, nonatomic) BOOL audioEnabled;

#pragma mark - Video
#pragma mark  AVCaptureSession

/**
 * Enable/Disable video stream
 */
@property (assign, nonatomic) BOOL videoEnabled;

@property(nonatomic, readonly) AVCaptureSession* captureSession;

/**
 *  Indicating the physical position of an AVCaptureDevice's hardware on the system.
 */
@property (assign, nonatomic, readonly) AVCaptureDevicePosition currentCaptureDevicePosition;

/**
 *  Switch Front / Back video input. (Default: Front camera)
 *
 *  @param block isFrontCamera YES/NO
 */
- (void)switchCamera:(void (^)(BOOL isFrontCamera))block;

@end
