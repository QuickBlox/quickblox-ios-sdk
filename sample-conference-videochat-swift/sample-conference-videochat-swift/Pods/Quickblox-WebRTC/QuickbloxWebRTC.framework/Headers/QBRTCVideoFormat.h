//
//  QBRTCVideoFormat.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCVideoFormat class interface.
 *  This class represents format management
 */
@interface QBRTCVideoFormat : NSObject <NSCoding>

/**
 *  Frame width.
 */
@property (nonatomic, assign) NSUInteger width;

/**
 *  Frame height.
 */
@property (nonatomic, assign) NSUInteger height;

/**
 *  Frames per second.
 */
@property (nonatomic, assign) NSUInteger frameRate;

/**
 *  Pixel format.
 */
@property (nonatomic, assign) QBRTCPixelFormat pixelFormat;

/**
 *  Initialize video format with all settings
 *
 *  @param width       frame width
 *  @param height      frame height
 *  @param frameRate   frame rate, default is 30 FPS
 *  @param pixelFormat QBRTCPixelFormat type
 *
 *  @return QBRTCVideoFormat instance
 */
+ (instancetype)videoFormatWithWidth:(NSUInteger)width
                              height:(NSUInteger)height
                           frameRate:(NSUInteger)frameRate
                         pixelFormat:(QBRTCPixelFormat)pixelFormat;

/**
 *  Default video format.
 *
 *  @remark width: 640
 *          height: 480
 *          framerate: 30
 *          pixelFormat: QBRTCPixelFormat420f
 *
 *  @return QBRTCVideoFormat instance
 */
+ (instancetype)defaultFormat;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
