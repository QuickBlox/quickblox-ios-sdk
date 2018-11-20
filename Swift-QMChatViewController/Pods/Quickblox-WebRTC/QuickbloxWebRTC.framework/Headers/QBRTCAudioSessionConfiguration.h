//
//  QBRTCAudioSessionConfiguration.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBRTCAudioSessionConfiguration : NSObject

/**
 *  Audio session category.
 *
 *  @remark Default value: AVAudioSessionCategoryPlayAndRecord
 *
 *  @see AVAudioSessionCategoryAmbient, AVAudioSessionCategorySoloAmbient, AVAudioSessionCategoryPlayback, AVAudioSessionCategoryRecord, AVAudioSessionCategoryPlayAndRecord, AVAudioSessionCategoryAudioProcessing and AVAudioSessionCategoryMultiRoute.
 */
@property (nonatomic, strong) NSString *category;

/**
 *  Audio session category options.
 *  
 *  @remark Default value: AVAudioSessionCategoryOptionDuckOthers
 */
@property (nonatomic, assign) AVAudioSessionCategoryOptions categoryOptions;

/**
 *  Audio session mode.
 *
 *  @remark Default value: AVAudioSessionModeVoiceChat
 *
 *  @see AVAudioSessionModeDefault, AVAudioSessionModeVoiceChat, AVAudioSessionModeGameChat, AVAudioSessionModeVideoRecording, AVAudioSessionModeMeasurement, AVAudioSessionModeMoviePlayback, AVAudioSessionModeVideoChat, AVAudioSessionModeSpokenAudio
 */
@property (nonatomic, strong) NSString *mode;

/**
 *  Init default audio session configuration.
 *
 *  @return QBRTCAudioSessionConfiguration instance with default setup.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
