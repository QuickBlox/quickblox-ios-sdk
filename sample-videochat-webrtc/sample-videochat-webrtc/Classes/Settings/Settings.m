//
//  Settings.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "Settings.h"


#pragma mark - keys

NSString *const kStunServerListKey = @"stunServerList";
NSString *const kVideoFormatKey = @"videoFormat";
NSString *const kPreferredCameraPosition = @"cameraPosition";
NSString *const kVideoRendererType = @"videoRendererType";
NSString *const kMediaConfigKey = @"mediaConfig";


// RTC Config
NSString *const kAnswerTimeInterval = @"answerTimeInterval";
NSString *const kDisconnectTimeInterval = @"disconnectTimeInterval";
NSString *const kDialingTimeInterval = @"dialingTimeInterval";
NSString *const kDTLSEnabled = @"dtlsenabled";

@implementation Settings

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self load];
    }
    
    return self;
}

- (void)saveToDisk {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *videoFormatData = [NSKeyedArchiver archivedDataWithRootObject:self.videoFormat];
    NSData *mediaConfig = [NSKeyedArchiver archivedDataWithRootObject:self.mediaConfiguration];
    
    [defaults setInteger:self.preferredCameraPosition forKey:kPreferredCameraPosition];
    
    [defaults setObject:self.stunServers forKey:kStunServerListKey];
    [defaults setObject:videoFormatData forKey:kVideoFormatKey];
    [defaults setObject:mediaConfig forKey:kMediaConfigKey];
	
	[defaults setDouble:self.answerTimeInterval forKey:kAnswerTimeInterval];
	[defaults setDouble:self.disconnectTimeInterval forKey:kDisconnectTimeInterval];
	[defaults setDouble:self.dialingTimeInterval forKey:kDialingTimeInterval];
	
	[defaults setBool:self.DTLSEnabled forKey:kDTLSEnabled];
	
    [defaults synchronize];
}

- (void)load {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.stunServers = [defaults arrayForKey:kStunServerListKey];
    
    AVCaptureDevicePosition position = (AVCaptureDevicePosition)[defaults integerForKey:kPreferredCameraPosition];
    
    if (position == AVCaptureDevicePositionUnspecified) {
        //First launch
        position = AVCaptureDevicePositionBack;
    }
    
    self.preferredCameraPosition = position;
    
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
	
	// RTCConfig
	
	// Answer time interval, min 10
	if ([defaults objectForKey:kAnswerTimeInterval]) {
		self.answerTimeInterval = [defaults doubleForKey:kAnswerTimeInterval];
	} else {
		self.answerTimeInterval = 45;
	}
	
	
	// Disconnect time interval, default 30
	if ([defaults objectForKey:kDisconnectTimeInterval]) {
		self.disconnectTimeInterval = [defaults doubleForKey:kDisconnectTimeInterval];
	} else {
		self.disconnectTimeInterval = 30;
	}
	
	
	// Dialing time interval default 5
	if ([defaults objectForKey:kDialingTimeInterval]) {
		self.dialingTimeInterval = [defaults doubleForKey:kDialingTimeInterval];
	} else {
		self.dialingTimeInterval = 5;
	}
	
	// DTLS enabled: default YES
	if ([defaults objectForKey:kDTLSEnabled]) {
		self.DTLSEnabled = [defaults boolForKey:kDTLSEnabled];
	} else {
		self.DTLSEnabled = YES;
	}
	
}

- (void)setAnswerTimeInterval:(NSTimeInterval)answerTimeInterval {
	if (answerTimeInterval != _answerTimeInterval) {
		_answerTimeInterval = answerTimeInterval;
		[QBRTCConfig setAnswerTimeInterval:answerTimeInterval];
	}
}

- (void)setDisconnectTimeInterval:(NSTimeInterval)disconnectTimeInterval {
	if (disconnectTimeInterval != _disconnectTimeInterval) {
		_disconnectTimeInterval = disconnectTimeInterval;
		[QBRTCConfig setDisconnectTimeInterval:disconnectTimeInterval];
	}
}

- (void)setDialingTimeInterval:(NSTimeInterval)dialingTimeInterval {
	if (dialingTimeInterval != _dialingTimeInterval) {
		_dialingTimeInterval = dialingTimeInterval;
		[QBRTCConfig setDialingTimeInterval:dialingTimeInterval];
	}
}

- (void)setDTLSEnabled:(BOOL)DTLSEnabled {
	if (DTLSEnabled != _DTLSEnabled) {
		_DTLSEnabled = DTLSEnabled;
		[QBRTCConfig setDTLSEnabled:DTLSEnabled];
	}
}


@end