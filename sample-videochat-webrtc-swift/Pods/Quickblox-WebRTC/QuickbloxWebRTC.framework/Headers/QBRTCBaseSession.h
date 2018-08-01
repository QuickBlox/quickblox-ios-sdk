//
//  QBRTCBaseSession.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

@class QBRTCMediaStream;
@class QBRTCAudioTrack;
@class QBRTCVideoTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCBaseSession class interface.
 *  This class represents basic session methods.
 */
@interface QBRTCBaseSession : NSObject

/**
 *  Conference type.
 *
 *  @remark
 QBRTCConferenceTypeVideo - video conference
 QBRTCConferenceTypeAudio - audio conference
 *
 *  @see QBRTCConferenceType
 */
@property (assign, nonatomic, readonly) QBRTCConferenceType conferenceType;

/**
 *  Session state.
 *
 *  @see QBRTCSessionState
 */
@property (assign, nonatomic, readonly) QBRTCSessionState state;

/**
 *  Current user ID.
 */
@property (assign, nonatomic, readonly) NSNumber *currentUserID;

/**
 *  Local media stream with audio and video (if video conferene) tracks.
 *
 *  @discussion QBRTCMediaStream instance that has both video and audio tracks and allows to manage them.
 */
@property (strong, nonatomic, readonly) QBRTCMediaStream *localMediaStream;

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Remote audio track with opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCAudioTrack audio track instance
 */
- (QBRTCAudioTrack *)remoteAudioTrackWithUserID:(NSNumber *)userID;

/**
 *  Remote video track with opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCVideoTrack video track instance
 */
- (QBRTCVideoTrack *)remoteVideoTrackWithUserID:(NSNumber *)userID;

/**
 *  Connection state for opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCConnectionState connection state for opponent user ID
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
