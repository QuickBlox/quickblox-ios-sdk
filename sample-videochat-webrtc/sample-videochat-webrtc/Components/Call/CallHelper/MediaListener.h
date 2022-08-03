//
//  MediaListener.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 06.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionsController.h"

@class QBRTCVideoTrack;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ReceivedRemoteVideoTrackHandler)(QBRTCVideoTrack *videoTrack, NSNumber *userID);
typedef void(^BroadcastHandler)(BOOL enabled);

@interface MediaListener : NSObject  <SessionsMediaListenerDelegate>

@property (nullable, nonatomic, readwrite, copy) ReceivedRemoteVideoTrackHandler onReceivedRemoteVideoTrack;
@property (nullable, nonatomic, readwrite, copy) BroadcastHandler onAudio;
@property (nullable, nonatomic, readwrite, copy) BroadcastHandler onVideo;
@property (nullable, nonatomic, readwrite, copy) BroadcastHandler onSharing;

@end

NS_ASSUME_NONNULL_END
