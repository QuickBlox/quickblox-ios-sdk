//
//  Settings.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureDevice.h>



@interface Settings : NSObject

@property (strong, nonatomic) QBRTCVideoFormat *videoFormat;
@property (strong, nonatomic) QBRTCMediaStreamConfiguration *mediaConfiguration;
@property (assign, nonatomic) AVCaptureDevicePosition preferredCameraPosition;
@property (strong, nonatomic) NSArray *stunServers;

// RTC Config

@property (nonatomic) NSTimeInterval answerTimeInterval;
@property (nonatomic) NSTimeInterval disconnectTimeInterval;
@property (nonatomic) NSTimeInterval dialingTimeInterval;
@property (nonatomic) BOOL DTLSEnabled;

// UI testing
@property (nonatomic) BOOL autoAcceptCalls;

- (void)saveToDisk;

@end
