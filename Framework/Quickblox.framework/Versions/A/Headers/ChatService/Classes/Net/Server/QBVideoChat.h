//
//  QBVideoChat.h
//  Quickblox
//
//  Created by IgorKh on 1/15/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface QBVideoChat : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
}

/** Custom video capture session */
@property (retain) AVCaptureSession *customVideoChatCaptureSession;

/** Set view to which will be rendered opponent's video stream */
@property (retain) UIView *viewToRenderOpponentVideoStream;

/** Set view to which will be rendered your video stream */
@property (retain) UIView *viewToRenderOwnVideoStream;

/** ID of video chat opponent */
@property (readonly) NSUInteger videoChatOpponentID;

/** A Boolean value that determines whether all video chat data transfered through relay, not p2p */
@property (readonly, getter=isRelayUsed) BOOL relayUsed;

/** Switch to back camera */
@property (nonatomic, assign) BOOL useBackCamera;

/** A Boolean value that determines whether camera flash is enabled */
@property (nonatomic, assign, getter=isCameraFlashEnabled) BOOL cameraFlashEnabled;

/** A Boolean value that determines whether microphone is enabled */ 
@property (nonatomic, assign, getter=isMicrophoneEnabled) BOOL microphoneEnabled;


/**
 Call user. After this your opponent will be receiving one call request per second during 15 seconds to QBChatDelegate's method 'chatDidReceiveCallRequestFromUser:conferenceType:'

 @param userID ID of opponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
*/
- (void)callUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType;

/**
 Call user. After this your opponent will be receiving one call request per second during 15 seconds to QBChatDelegate's method 'chatDidReceiveCallRequestFromUser:conferenceType:customMessage:
 
 @param userID ID of opponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 @param customParameters Custom parameters
 */
- (void)callUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters;

/**
 Сancel call requests which is producing 'callUser:' method
 */
- (void)cancelCall;

/**
 Accept call. Opponent will receive accept signal in QBChatDelegate's method 'chatCallDidAcceptByUser:'
 */
- (void)acceptCall;

/**
 Accept call with custom parameters. Opponent will receive accept signal in QBChatDelegate's method 'chatCallDidAcceptByUser:customParameters:'
 
 @param customParameters Custom parameters
 */
- (void)acceptCallWithCustomParameters:(NSDictionary *)customParameters;

/**
 Reject call. Opponent will receive reject signal in QBChatDelegate's method 'chatCallDidRejectByUser:'
 */
- (void)rejectCall;

/**
 Finish call. Opponent will receive finish signal in QBChatDelegate's method 'chatCallDidStopByUser:status:' with status=kStopVideoChatCallStatus_Manually 
 */
- (void)finishCall;

/**
 Finish call. Opponent will receive finish signal in QBChatDelegate's method 'chatCallDidStopByUser:status:customParameters:' with status=kStopVideoChatCallStatus_Manually
 
 @param customParameters Custom parameters
 */
- (void)finishCallWithCustomParameters:(NSDictionary *)customParameters;


/**
 Set current video session preset. The value of this property is an NSString (one of AVCaptureSessionPreset*).
 
 @param preset An AVCaptureSession preset.
 */
- (void)setVideoOutputPreset:(NSString *)preset;

/**
 Returns whether the video chat can be configured with the given preset. YES if can be set to the given preset, NO otherwise.
 
 @param preset An AVCaptureSession preset.
 */
- (BOOL)canSetVideoOutputPreset:(NSString *)preset;


/**
 If use custom capture session - use this method to back video output samples to video chat.
 
 @param sampleBuffer Video output sample
 */
- (void)processVideoChatCaptureVideoSample:(CMSampleBufferRef)sampleBuffer;

/**
 If novocain is initialized in client app - use this method to back audio data to video chat.
 
 @param data Audio data
 @param numFrames Number of frames
 @param numChannels Number of channels
 */
- (void)processVideoChatCaptureAudioData:(float *)data numFrames:(UInt32)numFrames numChannels:(UInt32) numChannels;



// TDB
- (void)drainWriteVideoQueue;
- (void)drainWriteAudioQueue;

@end
