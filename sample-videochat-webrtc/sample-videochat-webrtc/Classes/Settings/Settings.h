//
//  Settings.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@interface Settings : NSObject

@property (strong, nonatomic) QBRTCVideoFormat *videoFormat;

@property (strong, nonatomic) QBRTCMediaStreamConfiguration *mediaConfiguration;

@property (assign, nonatomic) QBRendererType remoteVideoViewRendererType;

@property (assign, nonatomic) AVCaptureDevicePosition preferredCameraPostion;

@property (assign, nonatomic) ListOfUsers listType;

@property (strong, nonatomic) NSArray *stunServers;

+ (instancetype)instance;

- (void)saveToDisk;

@end
