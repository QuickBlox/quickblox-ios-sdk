//
//  QBRTCVideoCapture.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 28/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCVideoFrame;
@class QBRTCLocalVideoTrack;

/**
 *  Class allows you to send frames to your opponent using video source( like camera, UIView etc. )
 */
@interface QBRTCVideoCapture : NSObject

/** Serial queue to process video frames
 *  For example AVCaptureVideoDataOutput needs a queue, so you can call
 *  AVCaptureVideoDataOutput instance setSampleBufferDelegate:self queue:self.videoQueue
 */
@property (nonatomic, strong, readonly) dispatch_queue_t videoQueue;

/// Called when video track is set
- (void)didSetToVideoTrack:(QBRTCLocalVideoTrack *)videoTrack;

/// Called when video track was removed
- (void)didRemoveFromVideoTrack:(QBRTCLocalVideoTrack *)videoTrack;

/// Send video frames to opponents
- (void)sendVideoFrame:(QBRTCVideoFrame *)frame;

@end
