//
//  QBVideoFrame.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
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

/**
 *  Initialize video frame with pixel buffer
 *
 *  @param pixelBuffer CVPixelBufferRef
 *
 *  @return QBRTCVideoFrame instance
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer videoRotation:(QBRTCVideoRotation)videoRotation;

@end
