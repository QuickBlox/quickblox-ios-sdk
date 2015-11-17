//
//  QBRTCMediaStreamConfiguration.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 04/11/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRTCAudioCodec) {
    
    QBRTCAudioCodecOpus,
    QBRTCAudioCodecISAC,
    QBRTCAudioCodeciLBC
};

typedef NS_ENUM(NSUInteger, QBRTCVideoCodec) {
    
    QBRTCVideoCodecVP8,  //  VP8 video codec, supported from iOS 7+
    QBRTCVideoCodecH264, // H264 video codec, supported from iOS 8+
};

#pragma mark - Codecs

/**
 *  QBRTCMediaStreamConfiguration class allows to configure audio and video settings
 *
 *  Default media stream configuration available with [QBRTCConfig mediaStreamConfiguration]
 *
 *  You can instantiate defaulConfiguration, change and then apply with [QBRTCConfig setMediaStreamConfiguration:]
 */
@interface QBRTCMediaStreamConfiguration : NSObject <NSCoding>

/**
 *  Audio codec
 *
 *  @note audioCodec QBRTCAudioCodecOpus, QBRTCAudioCodecISAC or QBRTCAudioCodeciLBC are possible values
 */
@property (nonatomic, assign) QBRTCAudioCodec audioCodec;

/**
 *  Audio bandwidth
 *
 *  When set to 0 it is skipped in session description
 */
@property (nonatomic, assign) NSInteger audioBandwidth;

/**
 *  Video codec
 *
 *  @param videoCodec QBRTCVideoCodecVP8 or QBRTCVideoCodecH264 are possible values
 */
@property (nonatomic, assign) QBRTCVideoCodec videoCodec;

/**
 *  Video bandwidth
 *
 *  When set to 0 it is skipped in session description
 */
@property (nonatomic, assign) NSInteger videoBandwidth;

/**
 *  Default media stream configuration with VP8 video codec and Opus audio codec
 *
 *  @return QBRTCMediaStreamConfiguration instance
 */
+ (instancetype)defaultConfiguration;

@end
