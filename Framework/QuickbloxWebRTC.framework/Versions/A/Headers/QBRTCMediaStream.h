//
//  QBLocalMediaStream.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 15.07.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCLocalVideoTrack;
@class QBRTCLocalAudioTrack;

/**
 *  Media stream class holds media information such as video and audio tracks
 *  Class is access from QBRTCSession class, localMediaStream property
 */
@interface QBRTCMediaStream : NSObject

/// Audio track, can be enabled or disabled
@property (strong, nonatomic, readonly) QBRTCLocalAudioTrack *audioTrack;

/// Video track, can be enabled or disabled
@property (strong, nonatomic, readonly) QBRTCLocalVideoTrack *videoTrack;

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
