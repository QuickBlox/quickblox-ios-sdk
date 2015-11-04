//
//  QBVideoFrame.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 08/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class QBRTCVideoFormat;

/**
 *  Entity for storing pixel buffer and corresponding information
 */
@interface QBRTCVideoFrame : NSObject

@property (nonatomic, assign, readonly) CVPixelBufferRef pixelBuffer;

/// Shows when the frame was captured, in unix time with nanosecond units.
@property (nonatomic, assign) int64_t timestamp;

/**
 *  Initialize video frame with pixel buffer
 *
 *  @param pixelBuffer CVPixelBufferRef
 *
 *  @return QBRTCVideoFrame instance
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
