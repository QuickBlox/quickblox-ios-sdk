//
//  Settings.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (strong, nonatomic) QBRTCVideoFormat *videoFormat;
@property (strong, nonatomic) QBRTCMediaStreamConfiguration *mediaConfiguration;
@property (assign, nonatomic) AVCaptureDevicePosition preferredCameraPostion;

- (void)saveToDisk;
- (void)applyConfig;

@end
