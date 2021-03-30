//
//  QBVideoFrame.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import "RTCVideoFrame.h"

/**
 *  Entity for storing pixel buffer and corresponding information.
 */
@interface QBRTCVideoFrame : RTCVideoFrame

@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, readonly) QBRTCVideoRotation videoRotation;

/**
 *  Initialize video frame with pixel buffer
 *
 *  @param pixelBuffer CVPixelBufferRef
 *
 *  @return QBRTCVideoFrame instance
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer videoRotation:(QBRTCVideoRotation)videoRotation;

@end
