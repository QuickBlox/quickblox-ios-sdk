//
//  QBRTCVideoCapture.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCVideoFrame;
@class QBRTCLocalVideoTrack;

/**
 *  Class allows you to send frames to your opponent using video source( like camera, UIView etc. )
 */
@interface QBRTCVideoCapture : NSObject

/**
 *  Serial queue to process video frames
 *  For example AVCaptureVideoDataOutput needs a queue, so you can call
 *  AVCaptureVideoDataOutput instance setSampleBufferDelegate:self queue:self.videoQueue
 */
@property (nonatomic, strong, readonly) dispatch_queue_t videoQueue;

/**
 * Executes a given block of code on the serial dispatch queue dedicated to video frame processing (`videoQueue`).
 * This method is particularly useful for tasks that need to be performed in a sequential and thread-safe manner,
 * such as processing video frames captured by an `AVCaptureVideoDataOutput` instance.
 *
 * If the current queue is already `videoQueue`, the block is executed immediately. Otherwise, the block is dispatched
 * asynchronously to `videoQueue`, ensuring it executes in the correct order relative to other blocks on the queue.
 *
 * @param block The block of code to be executed on the `videoQueue`. This block will be dispatched asynchronously
 *              if it is not already on the `videoQueue`.
 *
 * Usage:
 * Use this method to schedule tasks that need to be performed on the `videoQueue`, ensuring that all video frame
 * processing is handled in a consistent and orderly fashion. This helps avoid race conditions and ensures that video
 * frames are processed in the order they are received.
 */
- (void)runInVideoQueue:(dispatch_block_t)block;

/**
 *  Called when video track is set.
 *
 *  @param videoTrack local video track instance
 */
- (void)didSetToVideoTrack:(QBRTCLocalVideoTrack *)videoTrack;

/**
 *  Called when video track was removed.
 *
 *  @param videoTrack local video track instance
 */
- (void)didRemoveFromVideoTrack:(QBRTCLocalVideoTrack *)videoTrack;

/**
 *  Send video frames to opponents.
 *
 *  @param frame video frame to send
 */
- (void)sendVideoFrame:(__kindof QBRTCVideoFrame *)frame;

/**
 *  Adapt frames to a specific width, height and fps before sending.
 *
 *  @param width desired frame width
 *  @param height desired frame height
 *  @param fps desired fps
 *
 *  @discussion Calling this function will cause frames to be scaled down to the
 *              requested resolution. Also, frames will be cropped to match the
 *              requested aspect ratio, and frames will be dropped to match the
 *              requested fps. The requested aspect ratio is orientation agnostic and
 *              will be adjusted to maintain the input orientation, so it doesn't
 *              matter if e.g. 1280x720 or 720x1280 is requested.
 */
- (void)adaptOutputFormatToWidth:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps;

@end
