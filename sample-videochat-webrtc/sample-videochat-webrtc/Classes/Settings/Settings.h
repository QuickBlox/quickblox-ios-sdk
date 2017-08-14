//
//  Settings.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@class RecordSettings;

@interface Settings : NSObject

@property (strong, nonatomic) QBRTCVideoFormat *videoFormat;
@property (strong, nonatomic) QBRTCMediaStreamConfiguration *mediaConfiguration;
@property (assign, nonatomic) AVCaptureDevicePosition preferredCameraPostion;

@property (strong, nonatomic) RecordSettings *recordSettings;

+ (instancetype)instance;

- (void)saveToDisk;
- (void)applyConfig;

@end
