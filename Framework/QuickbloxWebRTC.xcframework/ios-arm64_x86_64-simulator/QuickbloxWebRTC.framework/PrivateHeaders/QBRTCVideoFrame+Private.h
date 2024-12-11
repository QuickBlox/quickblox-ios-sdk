//
//  QBRTCVideoFrame+Private.h
//  QuickbloxWebRTC
//
//  Copyright © 2024 QuickBlox Team. All rights reserved.
//

#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBRTCVideoFrame (Private)

@property (nonatomic, readonly) RTCVideoFrame *nativeFormat;

@end

NS_ASSUME_NONNULL_END
