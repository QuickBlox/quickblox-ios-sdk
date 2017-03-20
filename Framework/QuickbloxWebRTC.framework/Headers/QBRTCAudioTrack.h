//
//  QBRTCAudioTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

@protocol QBRTCAudioDataReceiver;

NS_ASSUME_NONNULL_BEGIN

/// Entity to describe remote audio track
@interface QBRTCAudioTrack : QBRTCMediaStreamTrack

// Sets the volume for the specific track. |volume] is a gain value in the range
// [0, 10].
@property (nonatomic, assign) double volume;

/// Init is not a supported initializer for this class.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
