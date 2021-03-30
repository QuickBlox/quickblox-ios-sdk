//
//  QBRTCRecorder.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QBRTCTypes.h"

@class QBRTCAudioTrack;
@class QBRTCVideoTrack;
@class QBRTCRecorder;

NS_ASSUME_NONNULL_BEGIN

/**
 QBRTCRecorder state.

 - QBRTCRecorderStateNotActive: not active
 - QBRTCRecorderStateActive: active and recording or waiting for media data
 - QBRTCRecorderStateFinalizing: finalizing recording file
 */
typedef NS_ENUM(NSUInteger, QBRTCRecorderState) {
    QBRTCRecorderStateNotActive,
    QBRTCRecorderStateActive,
    QBRTCRecorderStateFinalizing
};

@protocol QBRTCRecorderDelegate <NSObject>

/**
 Called when recorder did fail to record at some point.

 @param recorder QBRTCRecorder instance
 @param error specific error
 */
- (void)recorder:(QBRTCRecorder *)recorder didFailWithError:(NSError *)error;

@end

/**
 QBRTCRecorder class interface.
 This class represents webrtc audio/video recorder.
 */
@interface QBRTCRecorder : NSObject

/**
 Current output file url.
 */
@property (strong, nonatomic, readonly, nullable) NSURL *outputFileURL;

/**
 Recorder state.
 
 @see QBRTCRecorderState
 */
@property (assign, atomic, readonly) QBRTCRecorderState state;

/**
 Determines whether microphone should be muted on record.
 
 @discussion Can be set at any time of class instance life.
 */
@property (assign, nonatomic, getter=isMicrophoneMuted) BOOL microphoneMuted;

/**
 Determines whether local audio recording from the mic is enabled or not.
 
 @discussion Use this property to stop and/or re-start local mic audio record. Use it, for example, if you need to turn off the local audio record or restart the audio unit.
 @remark Default value is YES.
 */
@property (assign, nonatomic, getter=isLocalAudioEnabled) BOOL localAudioEnabled;

/**
 Delegate that conforms to QBRTCRecorderDelegate protocol.
 */
@property (weak, nonatomic, nullable) id<QBRTCRecorderDelegate> delegate;

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Set video recording format.
 
 @param width video width
 @param height video height
 @param bitrate video bitrate
 @param fps video fps
 
 @note You can only set this params while recording is not in active state (e.g. haven't started yet).
 
 @remark Default values are 640x480 with 636528 bitrate 30 fps
 
 @see https://www.dr-lex.be/info-stuff/videocalc.html for bitrate calculation
 */
- (void)setVideoRecordingWidth:(NSUInteger)width
                        height:(NSUInteger)height
                       bitrate:(NSUInteger)bitrate
                           fps:(NSUInteger)fps;

/**
 Set video recording orientation.
 
 @param videoRotation video rotation
 
 @note You can only set this params while recording is not in active state (e.g. haven't started yet).
 Cannot be changed mid record.
 
 @remark Default is 0 degrees, e.g. landscape orientation.
 */
- (void)setVideoRecordingRotation:(QBRTCVideoRotation)videoRotation;

/**
 Start record with url.
 
 @param url preferred file url
 
 @note Url must contain mp4 extension.
 */
- (void)startRecordWithFileURL:(NSURL *)url;

/**
 Stop record.
 
 @param completion completion block with file url if record was successful
 
 @discussion Async operation that might take some time until record is finalized.
 
 @note File url will be nil if record failed, didn't start or there was nothing to record.
 */
- (void)stopRecord:(nullable void (^)(NSURL * _Nullable file))completion;

@end

NS_ASSUME_NONNULL_END
