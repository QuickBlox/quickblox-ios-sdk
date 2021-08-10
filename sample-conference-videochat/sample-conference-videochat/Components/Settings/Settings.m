//
//  Settings.m
//  sample-conference-videochat
//
//  Created by Injoit on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
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
    NSData *videFormatData = [NSKeyedArchiver archivedDataWithRootObject:self.videoFormat requiringSecureCoding:NO error:nil];
    [defaults setObject:videFormatData forKey:kVideoFormatKey];
    NSData *mediaConfig = [NSKeyedArchiver archivedDataWithRootObject:self.mediaConfiguration requiringSecureCoding:NO error:nil];
    [defaults setObject:mediaConfig forKey:kMediaConfigKey];
    [defaults setInteger:self.preferredCameraPostion forKey:kPreferredCameraPosition];

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
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:videoFormatData error:nil];
        unarchiver.requiresSecureCoding = NO;
        self.videoFormat  = [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    } else {
        self.videoFormat = [QBRTCVideoFormat defaultFormat];
    }
    
    NSData *mediaConfigData = [defaults objectForKey:kMediaConfigKey];
    
    if (mediaConfigData) {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:mediaConfigData error:nil];
        unarchiver.requiresSecureCoding = NO;
        self.mediaConfiguration  = [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    } else {
        self.mediaConfiguration = [QBRTCMediaStreamConfiguration defaultConfiguration];
    }
    [self applyConfig];
}

@end
