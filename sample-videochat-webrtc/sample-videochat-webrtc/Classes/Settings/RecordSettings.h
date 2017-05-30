//
//  RecordSettings.h
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 4/18/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordSettings : NSObject <NSCoding>

@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

@property (assign, nonatomic) NSUInteger width;
@property (assign, nonatomic) NSUInteger height;
@property (assign, nonatomic) NSUInteger fps;

@property (assign, nonatomic) QBRTCVideoRotation videoRotation;

/**
 *  Calculates estimated bitrate for width, height and fps.
 *
 *  @return Estimated video bitrate
 */
- (NSUInteger)estimatedBitrate;

@end
