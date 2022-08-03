//
//  MediaController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 18.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "MediaController.h"
#import "Settings.h"
#import "VideoFormat.h"
#import "SharingScreenCapture.h"

@interface MediaController ()

@property (nonatomic, strong) QBRTCCameraCapture *camera;
@property (nonatomic, strong) SharingScreenCapture *sharing;

@property (nullable, nonatomic, strong) id appInactiveStateObserver;
@property (nullable, nonatomic, strong) id appActiveStateObserver;
@property (nonatomic, assign) BOOL didDiactivatedOutside;

@end

@implementation MediaController
@synthesize currentAudioOutput = _currentAudioOutput;

- (void)clear {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (self.appActiveStateObserver) {
        [defaultCenter removeObserver:(self.appActiveStateObserver)];
    }
    if (self.appInactiveStateObserver) {
        [defaultCenter removeObserver:(self.appInactiveStateObserver)];
    }
    self.appInactiveStateObserver = nil;
    self.appActiveStateObserver = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoEnabled = NO;
        _audioEnabled = YES;
        _sharingEnabled = NO;
        _didDiactivatedOutside = NO;
        
        __weak __typeof(self)weakSelf = self;
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        self.appActiveStateObserver = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:NSOperationQueue.mainQueue
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if (!weakSelf.didDiactivatedOutside) {
                return;
            }
            weakSelf.didDiactivatedOutside = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(mediaController:videoBroadcastEnable:capture:)]) {
                [weakSelf.delegate mediaController:weakSelf videoBroadcastEnable:YES capture:nil];
            }
        }];
        
        self.appInactiveStateObserver = [center addObserverForName:UIApplicationWillResignActiveNotification
                                                            object:nil
                                                             queue:NSOperationQueue.mainQueue
                                                        usingBlock:^(NSNotification * _Nonnull note) {
            if (!self.videoEnabled && !self.sharingEnabled) {
                return;
            }
            if ([weakSelf.delegate respondsToSelector:@selector(mediaController:videoBroadcastEnable:capture:)]) {
                [weakSelf.delegate mediaController:weakSelf videoBroadcastEnable:NO capture:nil];
            }
            weakSelf.didDiactivatedOutside = YES;
        }];
    }
    return self;
}

- (void)setAudioEnabled:(BOOL)audioEnabled {
    _audioEnabled = audioEnabled;
    if ([self.delegate respondsToSelector:@selector(mediaController:audioBroadcastEnable:reason:)]) {
        [self.delegate mediaController:self audioBroadcastEnable:audioEnabled reason:ChangeAudioStateReasonActionUser];
    }
}


- (void)setVideoEnabled:(BOOL)videoEnabled {
    _videoEnabled = videoEnabled;
    if (videoEnabled == YES && self.camera == nil) {
        Settings *settings = [[Settings alloc] init];
        self.camera = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                             position:settings.preferredCameraPostion];
    }
    if ([self.delegate respondsToSelector:@selector(mediaController:videoBroadcastEnable:capture:)]) {
        [self.delegate mediaController:self videoBroadcastEnable:videoEnabled capture:self.camera];
    }
}

- (void)setSharingEnabled:(BOOL)sharingEnabled {
    _sharingEnabled = sharingEnabled;
    if (sharingEnabled == YES) {
        self.sharing = [[SharingScreenCapture alloc] initWithVideoFormat:self.videoFormat];
        if ([self.delegate respondsToSelector:@selector(mediaController:videoBroadcastEnable:capture:)]) {
            [self.delegate mediaController:self videoBroadcastEnable:YES capture:self.sharing];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(mediaController:videoBroadcastEnable:capture:)]) {
        [self.delegate mediaController:self videoBroadcastEnable:self.videoEnabled capture:self.camera];
    }
    self.sharing = nil;
}

- (void)sendScreenContent:(CVPixelBufferRef)content {
    
    QBRTCVideoFrame *videoFrame =
    [[QBRTCVideoFrame alloc] initWithPixelBuffer:content
                                   videoRotation:QBRTCVideoRotation_0];
    [self.sharing sendVideoFrame:videoFrame];
}

- (void)setCurrentAudioOutput:(AVAudioSessionPortOverride)currentAudioOutput {
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    if (!audioSession.isActive) {
        return;
    }
    _currentAudioOutput = currentAudioOutput;
    [audioSession overrideOutputAudioPort:currentAudioOutput];
}

- (AVAudioSessionPortOverride)currentAudioOutput {
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    if (!audioSession.isActive) {return AVAudioSessionPortOverrideNone;}
    NSArray<AVAudioSessionPortDescription *> *outputs = [AVAudioSession.sharedInstance currentRoute].outputs;
    for (AVAudioSessionPortDescription *output in outputs) {
        return output.portType == AVAudioSessionPortBuiltInSpeaker ?
        AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
    }
    return AVAudioSessionPortOverrideNone;
}

- (QBRTCVideoTrack * _Nullable)videoTrackForUserID:(NSNumber *)userID {
    return [self.delegate mediaController:self videoTrackForUserID:userID];
}

// MARK: - CallKitManagerActionDelegate
- (void)callKit:(CallKitManager *)callKit didTapMute:(BOOL)isMuted {
    if (self.audioEnabled == !isMuted) {
        return;
    }
    _audioEnabled = !isMuted;
    if ([self.delegate respondsToSelector:@selector(mediaController:audioBroadcastEnable:reason:)]) {
        [self.delegate mediaController:self audioBroadcastEnable:!isMuted reason:ChangeAudioStateReasonActionCallKit];
    }
}

@end
