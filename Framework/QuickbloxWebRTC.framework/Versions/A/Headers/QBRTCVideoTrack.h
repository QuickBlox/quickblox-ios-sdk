//
//  QBWebRTCVideoTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RTCVideoRenderer;

/// Entity to describe video track class
@interface QBRTCVideoTrack : QBRTCMediaStreamTrack

/// Init is not a supported initializer for this class.
- (instancetype)init NS_UNAVAILABLE;

/** Register a renderer that will render all frames received on this track. */
- (void)addRenderer:(id<RTCVideoRenderer>)renderer;

/** Deregister a renderer. */
- (void)removeRenderer:(id<RTCVideoRenderer>)renderer;

@end

NS_ASSUME_NONNULL_END
