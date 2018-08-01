//
//  QBLocalMediaStream.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCLocalAudioTrack;
@class QBRTCLocalVideoTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Media stream class holds media information such as video and audio tracks
 *  Class is access from QBRTCSession class, localMediaStream property
 */
@interface QBRTCMediaStream : NSObject

/// Audio track, can be enabled or disabled
@property (strong, nonatomic, readonly) QBRTCLocalAudioTrack *audioTrack;

/// Video track, can be enabled or disabled
@property (strong, nonatomic, readonly) QBRTCLocalVideoTrack *videoTrack;

// Unavailable initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
