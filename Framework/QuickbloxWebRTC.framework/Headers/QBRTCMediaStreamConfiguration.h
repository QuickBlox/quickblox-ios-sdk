//
//  QBRTCMediaStreamConfiguration.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRTCAudioCodec) {
    
    QBRTCAudioCodecOpus,
    QBRTCAudioCodecISAC,
    QBRTCAudioCodeciLBC
};

typedef NS_ENUM(NSUInteger, QBRTCVideoCodec) {
    
    QBRTCVideoCodecVP8,  // VP8 video codec, software
    QBRTCVideoCodecH264, // H264 video codec, hardware, preferred
};

NS_ASSUME_NONNULL_BEGIN

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
 *  @remark QBRTCVideoCodecVP8 or QBRTCVideoCodecH264 are possible values
 */
@property (nonatomic, assign) QBRTCVideoCodec videoCodec;

/**
 *  Video bandwidth
 *
 *  When set to 0 it is skipped in session description
 */
@property (nonatomic, assign) NSInteger videoBandwidth;

/**
 *  Audio level control.
 *
 *  @discussion Determines whether webrtc audio level control is enabled. Rough example: slightly reducing
 *  audio volume for all tracks while you are talking (local audio track receiving sound).
 *
 *  @remark Default value: NO
 */
@property (nonatomic, assign, getter=isAudioLevelControlEnabled) BOOL audioLevelControlEnabled;

/**
 *  Default media stream configuration with H264 video codec and Opus audio codec
 *
 *  @return QBRTCMediaStreamConfiguration instance
 */
+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
