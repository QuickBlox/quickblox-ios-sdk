//
//  Settings.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "Settings.h"

#define settingsKey( prop ) NSStringFromSelector(@selector(prop))

#pragma mark - keys

static NSString * const kVideoFormatKey = @"videoFormat";
static NSString * const kPreferredCameraPosition = @"cameraPosition";
static NSString * const kMediaConfigKey = @"mediaConfig";

@implementation Settings

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self load];
    }
    
    return self;
}

- (void)saveToDisk {

    // saving to disk
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:self.preferredCameraPostion forKey:kPreferredCameraPosition];
    BOOL isDefaultPixelFormat = self.videoFormat.pixelFormat == QBRTCPixelFormat420f;
    [defaults setObject:@{ settingsKey(width): @(self.videoFormat.width),
                           settingsKey(height): @(self.videoFormat.height),
                           settingsKey(frameRate): @(self.videoFormat.frameRate),
                           settingsKey(pixelFormat): @(isDefaultPixelFormat) }
                 forKey:kVideoFormatKey];
    
    [defaults setObject:@{ settingsKey(audioCodec): @(self.mediaConfiguration.audioCodec),
                           settingsKey(audioBandwidth): @(self.mediaConfiguration.audioBandwidth),
                           settingsKey(videoCodec): @(self.mediaConfiguration.videoCodec),
                           settingsKey(videoBandwidth): @(self.mediaConfiguration.videoBandwidth),
                           settingsKey(isAudioLevelControlEnabled): @(self.mediaConfiguration.isAudioLevelControlEnabled) }
                 forKey:kMediaConfigKey];
    
    [defaults synchronize];
}

- (void)applyConfig {
    
    // saving to config
    [QBRTCConfig setMediaStreamConfiguration:self.mediaConfiguration];
}

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AVCaptureDevicePosition postion = [defaults integerForKey:kPreferredCameraPosition];
    if (postion == AVCaptureDevicePositionUnspecified) {
        //First launch
        postion = AVCaptureDevicePositionFront;
    }
    self.preferredCameraPostion = postion;
    
    NSDictionary<NSString *, NSNumber *> *videoInfo = [defaults objectForKey:kVideoFormatKey];
    if (videoInfo && [videoInfo isKindOfClass:[NSDictionary<NSString *, NSNumber *> class]]) {
        BOOL isDefaultPixelFormat = videoInfo[settingsKey(pixelFormat)].boolValue;
        QBRTCPixelFormat pixelFormat = isDefaultPixelFormat ? QBRTCPixelFormat420f : QBRTCPixelFormatARGB;
        self.videoFormat =
        [QBRTCVideoFormat videoFormatWithWidth:videoInfo[settingsKey(width)].unsignedIntegerValue
                                        height:videoInfo[settingsKey(height)].unsignedIntegerValue
                                     frameRate:videoInfo[settingsKey(frameRate)].unsignedIntegerValue
                                   pixelFormat:pixelFormat];
    } else {
        self.videoFormat = [QBRTCVideoFormat defaultFormat];
    }
    
    NSDictionary<NSString *, NSNumber *>*mediaInfo = [defaults objectForKey:kMediaConfigKey];
    
    if (mediaInfo) {
        self.mediaConfiguration = [QBRTCMediaStreamConfiguration defaultConfiguration];
        self.mediaConfiguration.audioCodec = mediaInfo[settingsKey(audioCodec)].unsignedIntegerValue;
        self.mediaConfiguration.audioBandwidth = mediaInfo[settingsKey(audioBandwidth)].unsignedIntegerValue;
        self.mediaConfiguration.videoCodec = mediaInfo[settingsKey(videoCodec)].unsignedIntegerValue;
        self.mediaConfiguration.videoBandwidth = mediaInfo[settingsKey(videoBandwidth)].unsignedIntegerValue;
        self.mediaConfiguration.audioLevelControlEnabled =
        mediaInfo[settingsKey(isAudioLevelControlEnabled)].boolValue;
        [self applyConfig];
    } else {
        self.mediaConfiguration = [QBRTCMediaStreamConfiguration defaultConfiguration];
    }
}

@end
