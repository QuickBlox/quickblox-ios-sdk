//
//  Settings.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "Settings.h"

#pragma mark - keys

NSString *const kVideoFormatKey = @"videoFormat";
NSString *const kPreferredCameraPosition = @"cameraPosition";
NSString *const kVideoRendererType = @"videoRendererType";
NSString *const kMediaConfigKey = @"mediaConfig";

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
    
    if (self) {
        [self load];
    }
    
    return self;
}

- (void)saveToDisk {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *videFormatData = [NSKeyedArchiver archivedDataWithRootObject:self.videoFormat];
    NSData *mediaConfig = [NSKeyedArchiver archivedDataWithRootObject:self.mediaConfiguration];
    
    [defaults setInteger:self.preferredCameraPostion forKey:kPreferredCameraPosition];
    [defaults setInteger:self.remoteVideoViewRendererType forKey:kVideoRendererType];
    
    [defaults setObject:videFormatData forKey:kVideoFormatKey];
    [defaults setObject:mediaConfig forKey:kMediaConfigKey];
    
    [defaults synchronize];
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
    }
    else {
        
        self.mediaConfiguration = [QBRTCMediaStreamConfiguration defaultConfiguration];
    }
    
    QBRendererType type = [defaults integerForKey:kVideoRendererType];
    self.remoteVideoViewRendererType = type;
}

@end