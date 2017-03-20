//
//  QBRTCLocalAudioTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCAudioTrack.h"

NS_ASSUME_NONNULL_BEGIN
/// Entity to describe remote audio track
@interface QBRTCLocalAudioTrack : QBRTCAudioTrack

// cannot set volume for local audio track
@property (nonatomic, assign) double volume NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
