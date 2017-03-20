//
//  QBRTCFrameConverter.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "QBRTCTypes.h"

@class RTCVideoFrame;

NS_ASSUME_NONNULL_BEGIN

/**
 * QBRTCFrameConverter class used to convert RTCI420Frame into desired format
 */
@interface QBRTCFrameConverter : NSObject

/**
 *  Preallocate pixel buffers for better real-time video, 
 *
 * internally calls CVPixelBufferPoolCreatePixelBufferWithAuxAttributes
 */
@property (nonatomic, assign) BOOL shouldPreallocateBuffers;

/**
 *  Initialize pixel buffer pool and preallocate pixel buffers if needed, then create pixel buffer
 *
 *  @param size CGSize struct with width and height
 *
 *  @return value shows whether we successfully created pixel buffer pool and pixel buffer
 */
- (BOOL)prepareForSourceSize:(CGSize)size;

/**
 *  Creates a CMSampleBufferRef. You must CFRelease this when you are finished with it.
 *
 *  @param frame source frame to copy
 *
 *  @return CFTypeRef accordingly to previously set QBRTCFrameConverterOutput
 */
- (CMSampleBufferRef)copyConvertedFrame:(RTCVideoFrame *)frame CF_RETURNS_RETAINED;

/**
 *   Gets rid of the output.
 */
- (void)flushFrame;

@end

NS_ASSUME_NONNULL_END
