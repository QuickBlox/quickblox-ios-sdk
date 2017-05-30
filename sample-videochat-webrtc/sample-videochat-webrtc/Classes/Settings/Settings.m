//
//  Settings.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "Settings.h"
#import "RecordSettings.h"

#pragma mark - keys

static NSString * const kVideoFormatKey = @"videoFormat";
static NSString * const kPreferredCameraPosition = @"cameraPosition";
static NSString * const kMediaConfigKey = @"mediaConfig";
static NSString * const kRecordSettingsKey = @"recordSettings";

@implementation Settings

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

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
    NSData *recordSettingsData = [NSKeyedArchiver archivedDataWithRootObject:self.recordSettings];
    
    [defaults setInteger:self.preferredCameraPostion forKey:kPreferredCameraPosition];
    [defaults setObject:videFormatData forKey:kVideoFormatKey];
    [defaults setObject:mediaConfig forKey:kMediaConfigKey];
    [defaults setObject:recordSettingsData forKey:kRecordSettingsKey];
    
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
    
    NSData *recordSettingsData = [defaults objectForKey:kRecordSettingsKey];
    if (recordSettingsData != nil) {
        self.recordSettings = [NSKeyedUnarchiver unarchiveObjectWithData:recordSettingsData];
    }
    else {
        self.recordSettings = [[RecordSettings alloc] init];
    }
}

@end
