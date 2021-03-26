//
//  QBRTCAudioTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import "QBRTCMediaStreamTrack.h"

#import <CoreAudio/CoreAudioTypes.h>
#import <CoreMedia/CoreMedia.h>

@class QBRTCAudioTrack;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCAudioTrackSinkInterface protocol.
 *  Used to sink audio data in real time for a specific audio track.
 */
@protocol QBRTCAudioTrackSinkInterface <NSObject>

/**
 *  Audio track sink interface callback.
 *
 *  @param audioTrack              QBRTCAudioTrack instance that is responsible for received audio data
 *  @param audioBufferList         audio buffer list with audio buffer (const)
 *  @param audioStreamDescription  audio stream description for audio buffer
 *  @param numberOfFrames          number of frames in current packet 
 *  @param time                    media timestamp in nano seconds scale
 *
 *  @note Do not modify audioBufferList struct in any way to avoid memory issues.
 *  But rather copy its data if you want to perform any memory modifications on audio data.
 */
-     (void)audioTrack:(QBRTCAudioTrack *)audioTrack
didSinkAudioBufferList:(const AudioBufferList *)audioBufferList
audioStreamDescription:(const AudioStreamBasicDescription)audioStreamDescription
        numberOfFrames:(size_t)numberOfFrames
                  time:(CMTime)time;

@end

/**
 *  QBRTCAudioTrack class interface.
 *  This class represents remote audio track.
 */
@interface QBRTCAudioTrack : QBRTCMediaStreamTrack

/**
 *  Volume of audio track.
 *
 *  @discussion Sets the volume for the specific track.
 *
 *  @remark |volume] is a gain value in the range [0, 10].
 */
@property (assign, nonatomic) double volume;

/**
 *  Add sink.
 *
 *  @param sink class instance that conforms to QBRTCAudioTrackSinkInterface protocol
 *
 *  @see QBRTCAudioTrackSinkInterface
 */
- (void)addSink:(id<QBRTCAudioTrackSinkInterface>)sink;

/**
 *  Remove sink.
 *
 *  @param sink class instance that conforms to QBRTCAudioTrackSinkInterface protocol
 *
 *  @see QBRTCAudioTrackSinkInterface
 */
- (void)removeSink:(id<QBRTCAudioTrackSinkInterface>)sink;

@end

NS_ASSUME_NONNULL_END
