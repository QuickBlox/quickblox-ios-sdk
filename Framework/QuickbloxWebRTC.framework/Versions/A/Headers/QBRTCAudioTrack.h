//
//  QBRTCAudioTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

@protocol QBRTCAudioDataReceiver;

NS_ASSUME_NONNULL_BEGIN

/// Entity to describe remote audio track
@interface QBRTCAudioTrack : QBRTCMediaStreamTrack

/// Init is not a supported initializer for this class.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
