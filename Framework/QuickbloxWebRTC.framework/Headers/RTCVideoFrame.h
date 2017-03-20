//
//  RTCVideoTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

NS_ASSUME_NONNULL_BEGIN

// RTCVideoFrame is an ObjectiveC version of webrtc::VideoFrame.
__attribute__((visibility("default")))
@interface RTCVideoFrame : NSObject

/** Width without rotation applied. */
@property(nonatomic, readonly) int width;

/** Height without rotation applied. */
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) QBRTCVideoRotation rotation;
/** Accessing YUV data should only be done for I420 frames, i.e. if nativeHandle
 *  is null. It is always possible to get such a frame by calling
 *  newI420VideoFrame.
 */
@property(nonatomic, readonly, nullable) const uint8_t *dataY;
@property(nonatomic, readonly, nullable) const uint8_t *dataU;
@property(nonatomic, readonly, nullable) const uint8_t *dataV;
@property(nonatomic, readonly) int strideY;
@property(nonatomic, readonly) int strideU;
@property(nonatomic, readonly) int strideV;

/** Timestamp in nanoseconds. */
@property(nonatomic, readonly) int64_t timeStampNs;

/** The native handle should be a pixel buffer on iOS. */
@property(nonatomic, readonly) CVPixelBufferRef nativeHandle;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/** Initialize an RTCVideoFrame from a pixel buffer, rotation, and timestamp.
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                           rotation:(QBRTCVideoRotation)rotation
                        timeStampNs:(int64_t)timeStampNs;

/** Initialize an RTCVideoFrame from a pixel buffer combined with cropping and
 *  scaling. Cropping will be applied first on the pixel buffer, followed by
 *  scaling to the final resolution of scaledWidth x scaledHeight.
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                        scaledWidth:(int)scaledWidth
                       scaledHeight:(int)scaledHeight
                          cropWidth:(int)cropWidth
                         cropHeight:(int)cropHeight
                              cropX:(int)cropX
                              cropY:(int)cropY
                           rotation:(QBRTCVideoRotation)rotation
                        timeStampNs:(int64_t)timeStampNs;

/** Return a frame that is guaranteed to be I420, i.e. it is possible to access
 *  the YUV data on it.
 */
- (RTCVideoFrame *)newI420VideoFrame;

@end

NS_ASSUME_NONNULL_END
