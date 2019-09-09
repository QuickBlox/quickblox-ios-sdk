//
//  Settings.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "Settings.h"

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
    NSData *videFormatData = [NSKeyedArchiver archivedDataWithRootObject:self.videoFormat];
    NSData *mediaConfig = [NSKeyedArchiver archivedDataWithRootObject:self.mediaConfiguration];
    
    [defaults setInteger:self.preferredCameraPostion forKey:kPreferredCameraPosition];
    [defaults setObject:videFormatData forKey:kVideoFormatKey];
    [defaults setObject:mediaConfig forKey:kMediaConfigKey];
    
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
    
    NSData *videoFormatData = [defaults objectForKey:kVideoFormatKey];
    if (videoFormatData) {
        
        self.videoFormat = [NSKeyedUnarchiver unarchiveObjectWithData:videoFormatData];
        
    }
    else {

        self.videoFormat = [QBRTCVideoFormat defaultFormat];
    }
    
    NSData *mediaConfigData = [defaults objectForKey:kMediaConfigKey];
    
    if (mediaConfigData) {
        self.mediaConfiguration = [NSKeyedUnarchiver unarchiveObjectWithData:mediaConfigData];
        [self applyConfig];
    }
    else {
        
        self.mediaConfiguration = [QBRTCMediaStreamConfiguration defaultConfiguration];
    }
}

@end
