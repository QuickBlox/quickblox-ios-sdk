//
//  SessionsController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "MediaController.h"

@class SessionsController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MediaType) {
    MediaTypeVideo,
    MediaTypeAudio,
    MediaTypeSharing
};

typedef NS_ENUM(NSInteger, SessionState) {
    SessionStateNew,
    SessionStateWait,
    SessionStateReceived,
    SessionStateApproved,
    SessionStateRejected
};


@protocol SessionsControllerDelegate <NSObject>

- (void)controller:(SessionsController *)controller
 didEndWaitSession:(NSString *)sessionId;

- (void)controller:(SessionsController *)controller
  didAcceptSession:(NSString *)sessionId;

- (void)controller:(SessionsController *)controller
   didCloseSession:(NSString *)sessionId;

- (void)controller:(SessionsController *)controller
didReceiveIncomingSession:(NSDictionary *)payload;

- (void)controller:(SessionsController *)controller
didChangeAudioState:(BOOL)enabled
           session:(NSString *)sessionId;

@end


@protocol SessionsMediaListenerDelegate <NSObject>

- (void)controller:(SessionsController *)controller didBroadcastMediaType:(MediaType)mediaType enabled:(BOOL)enabled;

- (void)controller:(SessionsController *)controller
didReceivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

@end


@interface SessionsController : NSObject
@property (nonatomic, weak) id<SessionsControllerDelegate> delegate;
@property (nonatomic, weak) id<SessionsMediaListenerDelegate> mediaListenerDelegate;

@property (nonatomic, strong, readonly) NSString *activeSessionId;

- (NSDictionary *)activateWithMembers:(NSDictionary<NSNumber *, NSString *>*)members
                                       hasVideo:(BOOL)hasVideo;

- (void)activate:(NSString *)sessionId timestamp:(NSString * _Nullable)timestamp;

- (BOOL)session:(NSString *)sessionId confirmToState:(SessionState)state;

- (void)start:(NSString *)sessionId
         userInfo:(NSDictionary<NSString *, NSString *> * _Nullable)info;

- (void)accept:(NSString *)sessionId
          userInfo:(NSDictionary<NSString *, NSString *> * _Nullable)info;

- (void)reject:(NSString *)sessionId
          userInfo:(NSDictionary<NSString *, NSString *> * _Nullable)info;

- (void)deactivate:(NSString *)sessionId;

@end

@interface SessionsController (Media) <MediaControllerDelegate>
@end

NS_ASSUME_NONNULL_END
