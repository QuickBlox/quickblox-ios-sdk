//
//  QBRTCFrameConverter.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 30.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

typedef NS_ENUM(NSUInteger, QBRTCFrameConverterOutput) {
    
    /**
     * Slower than CVPixelBuffer backing, as our NSData is not shared with the GPU
     */
    QBRTCFrameConverterOutputCGImageBackedByNSData,
    
    /**
     *  Fastest option for CGImages. YUV->RGB is out of place, backing store is an IOSurface.
     */
    QBRTCFrameConverterOutputCGImageBackedByCVPixelBuffer,
    
    /**
     * Slower than above because we have to do an additional copy to create a CGImage
     */
    QBRTCFrameConverterOutputCGImageCopiedFromCVPixelBuffer,
    
    /**
     *  Sample/pixel buffers is created properly, and is displayed on iOS 8.
     */
    QBRTCFrameConverterOutputCMSampleBufferBackedByCVPixelBuffer,  //
    
    /**
     *  Sample/pixel buffers is created properly, and needs testing iOS 8.
     */
    QBRTCFrameConverterOutputCMSampleBufferBackedByCVPixelBufferBGRA,
    
    /**
     *  Pixel buffer appears to be created properly. This could be useful with an OpenGL renderer
     */
    QBRTCFrameConverterOutputCVPixelBufferCopiedFromSource
};

@class RTCI420Frame;

/**
 * QBRTCFrameConverter class used to convert RTCI420Frame into desired format
 */
@interface QBRTCFrameConverter : NSObject

@property (nonatomic, assign, readonly) QBRTCFrameConverterOutput outputType;

/**
 *  Preallocate pixel buffers for better real-time video, 
 *
 * internally calls CVPixelBufferPoolCreatePixelBufferWithAuxAttributes
 */
@property (nonatomic, assign) BOOL shouldPreallocateBuffers;

/**
 *  Initialize converter with output format type
 *
 *  If output is QBRTCFrameConverterOutputCGImageBackedByCVPixelBuffer
 or QBRTCFrameConverterOutputCMSampleBufferBackedByCVPixelBufferBGRA
 and iOS >= 8 then we use accelerated conversion from YpCbCr to ARGB pixel format using vImageConvert_YpCbCrToARGB_GenerateConversion method
 *
 *  @param output output format
 *
 *  @return QBRTCFrameConverter instance
 */
- (instancetype)initWithOutput:(QBRTCFrameConverterOutput)output NS_DESIGNATED_INITIALIZER;

/**
 *  Initialize converter with output format type
 *
 *  If output is QBRTCFrameConverterOutputCGImageBackedByCVPixelBuffer
     or QBRTCFrameConverterOutputCMSampleBufferBackedByCVPixelBufferBGRA
     and iOS >= 8 then we use accelerated conversion from YpCbCr to ARGB pixel format using vImageConvert_YpCbCrToARGB_GenerateConversion method
 *
 *  @param output output format
 *
 *  @return QBRTCFrameConverter instance
 */
+ (instancetype)converterWithOutput:(QBRTCFrameConverterOutput)output;

/**
 *  Initialize pixel buffer pool and preallocate pixel buffers if needed, then create pixel buffer
 *
 *  @param dimensions CMVideoDimensions struct with width and height
 *
 *  @return value shows whether we successfully created pixel buffer pool and pixel buffer
 */
- (BOOL)prepareForSourceDimensions:(CMVideoDimensions)dimensions;

/**
 *  Creates a CGImageRef, CVPixelBuffer, or CMSampleBufferRef. You must CFRelease this when you are finished with it.
 *
 *  @param frame source frame to copy
 *
 *  @return CFTypeRef accordingly to previously set QBRTCFrameConverterOutput
 */
- (CFTypeRef)copyConvertedFrame:(RTCI420Frame *)frame CF_RETURNS_RETAINED;

/**
 *   Gets rid of the output.
 */
- (void)flushFrame;

/**
 *  Recommended output format for the max performance
 *
 *  @return QBRTCFrameConverterOutputCGImageBackedByCVPixelBuffer
 */
+ (QBRTCFrameConverterOutput)recommendedOutputFormat;

@end
