//
//  QBRTCVideoRenderer.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 04/09/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTCVideoRenderer;
@class QBRTCVideoTrack;

/**
 * Video Renderer is base class used to renderer video frames from videoTrack on rendererView
 * @see QBRTCRemoteVideoView
 */
@interface QBRTCVideoRenderer : NSObject

// Renderer
@property (nonatomic, weak) id <RTCVideoRenderer> renderer;

// Remote video track
@property (nonatomic, weak) QBRTCVideoTrack *videoTrack;

// Renderer view to display frames
@property (nonatomic, strong, readonly) UIView *rendererView;

/// Set video track and add self as renderer
- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack;

@end
