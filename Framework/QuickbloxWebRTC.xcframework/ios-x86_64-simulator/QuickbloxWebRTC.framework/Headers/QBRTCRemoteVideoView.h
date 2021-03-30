//
//  QBRTCRemoteVideoView.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "RTCVideoRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@class QBRTCRemoteVideoView;
@class QBRTCVideoTrack;

@protocol QBRTCRemoteVideoViewDelegate

/**
 *  Called when video view size was changed.
 *
 *  @param videoView QBRTCRemoteVideoView instance
 *  @param size new size
 */
- (void)videoView:(QBRTCRemoteVideoView *)videoView didChangeVideoSize:(CGSize)size;

@end

/**
 *  QBRTCRemoteVideoView is an RTCVideoRenderer which renders video frames in its
 *  bounds using OpenGLES 2.0.
 */
@interface QBRTCRemoteVideoView : UIView <RTCVideoRenderer>

/**
 *  Determines whether MetalKit should be used for drawing video frames (when possible).
 *  If not, GLKit will be used instead.
 *
 *  @discussion Using MetalKit always if available which is the best performance wise. Otherwise
 *  just using old method by drawing video frames with GLKit.
 *
 *  @remark Default value is YES. This is a class property and will be used by every instance of the class.
 *
 *  @see https://developer.apple.com/documentation/metalkit
 */
@property (nonatomic, assign, class) BOOL preferMetal;

/**
 *  Delegate that conforms to QBRTCRemoteVideoViewDelegate protocol.
 *
 *  @see QBRTCRemoteVideoViewDelegate
 */
@property (nonatomic, weak) id<QBRTCRemoteVideoViewDelegate> delegate;

/**
 *	Options are AVLayerVideoGravityResizeAspect, AVLayerVideoGravityResizeAspectFill
 *  and AVLayerVideoGravityResize. AVLayerVideoGravityResizeAspect is default.
 *  See <AVFoundation/AVAnimation.h> for a description of these options.
 *
 *  Default value: AVLayerVideoGravityResize
 */
@property (nonatomic, copy) NSString *videoGravity;

/** @abstract Enables/disables rendering.
 */
@property(nonatomic, getter=isEnabled) BOOL enabled;

/** @abstract Wrapped QBRTCVideoRotation, or nil.
 */
@property(nonatomic, nullable) NSValue* rotationOverride;

/**
 *  Set video track
 *
 *  @param videoTrack QBRTCVideoTrack instance
 */
- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack;

@end

NS_ASSUME_NONNULL_END
