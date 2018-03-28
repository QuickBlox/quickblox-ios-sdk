//
//  QBRTCMediaStreamConfiguration.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRTCAudioCodec) {
    
    QBRTCAudioCodecOpus,
    QBRTCAudioCodecISAC,
    QBRTCAudioCodeciLBC
};

/**
 Video codec description.

 - QBRTCVideoCodecVP8: VP8 software supported video codec
 - QBRTCVideoCodecH264Baseline: H264 baseline hardware supported video codec, preferred, low-cost
 - QBRTCVideoCodecH264High: H264 high hardware supported video codec for high resolutions, primary profile for broadcast
 
 @discussion H264 is the best one for iOS devices, since it is hardware supported. Use it whenever is possible. H264 baseline is the best solution for your typical video calls
 */
typedef NS_ENUM(NSUInteger, QBRTCVideoCodec) {
    
    QBRTCVideoCodecVP8,
    QBRTCVideoCodecH264Baseline,
    QBRTCVideoCodecH264High,
    QBRTCVideoCodecH264 __deprecated_enum_msg("Deprecated in 2.7. Use QBRTCVideoCodecH264Baseline instead.") = QBRTCVideoCodecH264Baseline
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
