//
//  QBWebRTCVideoTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import "QBRTCMediaStreamTrack.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RTCVideoRenderer;

/**
 *  QBRTCVideoTrack class interface.
 *  This class represents remote audio track.
 */
@interface QBRTCVideoTrack : QBRTCMediaStreamTrack

/**
 *  Register a renderer that will render all frames received on this track.
 *
 *  @param renderer class that conforms to RTCVideoRenderer protocol
 *
 *  @see RTCVideoRenderer
 */
- (void)addRenderer:(id<RTCVideoRenderer>)renderer;

/**
 *  Unregister a renderer.
 *
 *  @param renderer class that conforms to RTCVideoRenderer protocol
 *
 *  @see RTCVideoRenderer
 */
- (void)removeRenderer:(id<RTCVideoRenderer>)renderer;

@end

NS_ASSUME_NONNULL_END
