//
//  QBVideoChat.h
//  Quickblox
//
//  Created by IgorKh on 1/15/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "QBXMPPStream.h"


// video chat control messages
#define qbvideochat_pattern @"qbvideochat_"
#define qbvideochat_call @"qbvideochat_call"
#define qbvideochat_acceptCall @"qbvideochat_acceptCall"
#define qbvideochat_rejectCall @"qbvideochat_rejectCall"
#define qbvideochat_stopCall @"qbvideochat_stopCall"
#define qbvideochat_sendPublicAddress @"qbvideochat_sendPublicAddress"
#define qbvideochat_IAllocRelayOnTURN @"qbvideochat_IAllocRelayOnTURN"
#define qbvideochat_sendTURNRelayAddress @"qbvideochat_sendTURNRelayAddress"


@interface QBVideoChat : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    
}
@property (assign) NSUInteger videoChatOpponentID;

+ (QBVideoChat *)instanceWithXMPPStream:(QBXMPPStream *)xmppStream;

- (void)callUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType;
- (void)acceptCall;
- (void)rejectCall;
- (void)finishCall;

- (void)enableMicrophone:(BOOL)isEnable;

- (void)didReceiveVideoMessage:(QBXMPPMessage *)message;

@end
