//
//  QBRTCRemoteVideoView.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 13/08/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBRTCTypes.h"

@class QBRTCVideoTrack;

@protocol QBRTCRemoteVideoViewDelegate;

typedef NS_ENUM(NSUInteger, QBRendererType) {
    
    QBRendererTypeSampleBuffer = 0, // Native renderer, supports acceleration on iOS 8+
    QBRendererTypeEAGL = 1 // OpenGL renderer
};

/// Class used to display remote video track from opponent
@interface QBRTCRemoteVideoView : UIView

//Default QBRendererType QBRendererTypeSampleBuffer;
@property (assign, nonatomic, readonly) QBRendererType rendererType;

/**
 *  Set video track
 *
 *  @param videoTrack QBRTCVideoTrack instance
 */
- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack;

@end
