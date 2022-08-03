//
//  ParticipantsView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 27.09.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParticipantsView : UIView
@property (strong, nonatomic, readonly) CallInfo *callInfo;
@property (assign, nonatomic, readonly) QBRTCConferenceType conferenceType;
- (void)setupWithCallInfo:(CallInfo *)callInfo conferenceType:(QBRTCConferenceType)conferenceType;
- (void)addLocalVideo:(UIView *)videoView;
- (void)setupVideoTrack:(QBRTCVideoTrack *)videoTrack participantId:(NSNumber *)participantId;
- (void)setupVideoViewHidden:(BOOL)hidden participantId:(NSNumber *)participantId;
- (void)setupVideoViewAnimation:(CATransition *)animation participantId:(NSNumber *)participantId;
- (void)setupConnectionState:(QBRTCConnectionState)connectionState participantId:(NSNumber *)participantId;
@end

NS_ASSUME_NONNULL_END
