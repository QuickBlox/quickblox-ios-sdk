//
//  QBRTCVideoFormat.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 05/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

/**
 *  Class describes video format
 */
@interface QBRTCVideoFormat : NSObject <NSCoding>

/// Pixel format
@property (nonatomic, assign) QBRTCPixelFormat pixelFormat;

/// frame width
@property (nonatomic, assign) NSUInteger width;

/// Frame height
@property (nonatomic, assign) NSUInteger height;

/// Frames per second
@property (nonatomic, assign) NSUInteger frameRate;

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
 *  Default video format
 *  width: 640
 *  height: 480
 *  framerate: 30
 *  pixel format: QBRTCPixelFormat420f
 *  @return QBRTCVideoFormat instance
 */
+ (instancetype)defaultFormat;
- (instancetype)init;

@end
