//
//  MediaListener.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 06.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "MediaListener.h"

@implementation MediaListener

- (void)controller:(nonnull SessionsController *)controller didBroadcastMediaType:(MediaType)mediaType enabled:(BOOL)enabled {
    switch (mediaType) {
        case MediaTypeAudio:
            if (self.onAudio) {
                self.onAudio(enabled);
            }
            break;
        case MediaTypeVideo:
            if (self.onVideo) {
                self.onVideo(enabled);
            }
            break;
        case MediaTypeSharing:
            if (self.onSharing) {
                self.onSharing(enabled);
            }
            break;
    }
}

- (void)controller:(nonnull SessionsController *)controller didReceivedRemoteVideoTrack:(nonnull QBRTCVideoTrack *)videoTrack fromUser:(nonnull NSNumber *)userID {
    if (self.onReceivedRemoteVideoTrack) {
        self.onReceivedRemoteVideoTrack(videoTrack, userID);
    }
}

@end
