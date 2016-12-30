//
//  QBVideoFrame.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class QBRTCVideoFormat;

/**
 *  Entity for storing pixel buffer and corresponding information
 */
@interface QBRTCVideoFrame : NSObject

@property (nonatomic, assign, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign, readonly) QBRTCVideoRotation videoRotation;

/// Shows when the frame was captured, in unix time with ms units.
@property (nonatomic, assign) int64_t timestamp DEPRECATED_MSG_ATTRIBUTE("Depricate in 2.2. No longer in use due to webRTC specification.");

/**
 *  Initialize video frame with pixel buffer
 *
 *  @param pixelBuffer CVPixelBufferRef
 *
 *  @return QBRTCVideoFrame instance
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer videoRotation:(QBRTCVideoRotation)videoRotation;

@end

@interface QBRTCVideoFrame (Deprecated)

/**
 *  Initialize video frame with pixel buffer
 *
 *  @param pixelBuffer CVPixelBufferRef
 *
 *  @warning *Deprecated in 2.3.* Use 'initWithPixelBuffer:videoRotation:' instead.
 *
 *  @return QBRTCVideoFrame instance
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'initWithPixelBuffer:videoRotation:' instead.");

@end
