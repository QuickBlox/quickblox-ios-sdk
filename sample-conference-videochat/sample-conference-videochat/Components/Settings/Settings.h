//
//  Settings.h
//  sample-conference-videochat
//
//  Created by Injoit on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (strong, nonatomic) QBRTCVideoFormat *videoFormat;
@property (strong, nonatomic) QBRTCMediaStreamConfiguration *mediaConfiguration;
@property (assign, nonatomic) AVCaptureDevicePosition preferredCameraPostion;

- (void)saveToDisk;
- (void)applyConfig;

@end
