//
//  RecordSettings.m
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 4/18/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import "RecordSettings.h"

static const double multiplier_coef = 0.07;
static const int motion_coef = 1;

static NSString * const kEnabledKey = @"recordingEnabled";
static NSString * const kWidthKey = @"recordingWidth";
static NSString * const kHeightKey = @"recordingHeight";
static NSString * const kFpsKey = @"recordingFps";
static NSString * const kVideoRotationKey = @"recordingVideoRotation";

@implementation RecordSettings

// MARK: Construction

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _width = 640;
        _height = 480;
        _fps = 30;
    }
    return self;
}

// MARK: NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        _enabled = [aDecoder decodeBoolForKey:kEnabledKey];
        _width = [aDecoder decodeIntegerForKey:kWidthKey];
        _height = [aDecoder decodeIntegerForKey:kHeightKey];
        _fps = [aDecoder decodeIntegerForKey:kFpsKey];
        _videoRotation = [aDecoder decodeIntegerForKey:kVideoRotationKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:_enabled forKey:kEnabledKey];
    [aCoder encodeInteger:_width forKey:kWidthKey];
    [aCoder encodeInteger:_height forKey:kHeightKey];
    [aCoder encodeInteger:_fps forKey:kFpsKey];
    [aCoder encodeInteger:_videoRotation forKey:kVideoRotationKey];
}

// MARK: Public

- (NSUInteger)estimatedBitrate {
    return _width*_height*_fps*motion_coef*multiplier_coef;
}

@end
