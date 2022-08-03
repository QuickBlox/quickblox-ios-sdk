//
//  MediaController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 18.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallKitManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChangeAudioStateReason) {
    ChangeAudioStateReasonActionUser = 0,
    ChangeAudioStateReasonActionCallKit
};

@class QBRTCCameraCapture;
@class QBRTCVideoCapture;
@class QBRTCAudioTrack;
@class QBRTCVideoTrack;
@class VideoFormat;
@class SharingFormat;

@class MediaController;

@protocol MediaControllerDelegate <NSObject>
- (void)mediaController:(MediaController *)mediaController audioBroadcastEnable:(BOOL)enabled reason:(ChangeAudioStateReason)reason;
- (void)mediaController:(MediaController *)mediaController
   videoBroadcastEnable:(BOOL)enabled capture:(QBRTCVideoCapture * _Nullable)capture;
- (QBRTCVideoTrack * _Nullable)mediaController:(MediaController *)mediaController
                 videoTrackForUserID:(NSNumber *)userID;
@end

@interface MediaController : NSObject<CallKitManagerActionDelegate>

@property (nullable, nonatomic, weak) id<MediaControllerDelegate> delegate;

@property (nonatomic, strong, readonly) QBRTCCameraCapture * _Nullable camera;
@property (nonatomic, strong, readonly) QBRTCVideoCapture * _Nullable sharing;
@property (nonatomic, assign) AVAudioSessionPortOverride currentAudioOutput;

/// Video broadcast.
@property (nonatomic, assign) BOOL videoEnabled;
/// Audio broadcast.
@property (nonatomic, assign) BOOL audioEnabled;
/// Sharing broadcast.
@property (nonatomic, assign) BOOL sharingEnabled;

@property (nonatomic, strong) VideoFormat *videoFormat;
@property (nonatomic, strong) SharingFormat *sharingFormat;

- (void)sendScreenContent:(CVPixelBufferRef)content;
- (void)clear;

- (QBRTCVideoTrack * _Nullable)videoTrackForUserID:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
