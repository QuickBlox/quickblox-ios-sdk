//
//  QBGLVideoView.h
//  QuickbloxWebRTC
//
//  Created by Andrey on 10.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//
#import <UIKit/UIKit.h>

@class QBRTCVideoTrack;
@protocol QBGLVideoViewDelegate;

@interface QBGLVideoView : UIView

/**
 *  Skip black frames, default value NO (experimental)
 */
@property (assign, nonatomic) BOOL skipBlackFrames;

@property (weak, nonatomic) id <QBGLVideoViewDelegate> delegate;

/**
 *  Set video track
 *
 *  @param videoTrack QBRTCVideoTrack instance
 */
- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack;

@end

@protocol QBGLVideoViewDelegate <NSObject>

/**
 *  Called in case when video size changed
 *
 *  @param videoView QBGLVideoView instance
 *  @param size      new size
 */
- (void)videoView:(QBGLVideoView *)videoView didChangeVideoSize:(CGSize)size;

@end