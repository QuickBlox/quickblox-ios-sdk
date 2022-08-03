//
//  ParticipantsView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 27.09.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "ParticipantsView.h"
#import "ParticipantVideoView.h"
#import "ParticipantView.h"
#import "CallParticipant.h"
#import "LocalVideoView.h"
#import "Profile.h"

@interface ParticipantsView()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIStackView *topStackView;
@property (weak, nonatomic) IBOutlet UIStackView *bottomStackView;
//MARK: - Properties
@property (strong, nonatomic) CallInfo *callInfo;
@property (assign, nonatomic) QBRTCConferenceType conferenceType;
@end

@implementation ParticipantsView
//MARK: - Public Methods
- (void)setupWithCallInfo:(CallInfo *)callInfo conferenceType:(QBRTCConferenceType)conferenceType {
    self.conferenceType = conferenceType;
    self.callInfo = callInfo;
    
    __weak __typeof(self)weakSelf = self;
    [self.callInfo setOnUpdatedParticipant:^(NSNumber * _Nonnull userID, NSString * _Nonnull fullName) {
        __typeof(weakSelf)strongSelf = weakSelf;
        ParticipantView *participantView = (ParticipantView *)[strongSelf participantViewWithUserID:userID];
        participantView.name = fullName;
    }];
    
    for (CallParticipant *participant in self.callInfo.interlocutors) {
        UIView *participantView = self.conferenceType == QBRTCConferenceTypeVideo ?
        [self createParticipantVideoViewWithParticipant:participant]
        : [self createParticipantViewWithParticipant:participant] ;
        BOOL viewIsFull = self.topStackView.arrangedSubviews.count == 2;
        if (viewIsFull) {
            [self.bottomStackView addArrangedSubview:participantView];
            return;
        }
        [self.topStackView addArrangedSubview:participantView];
    }
}

- (void)addLocalVideo:(UIView *)videoView {
    ParticipantVideoView *participantView = (ParticipantVideoView *)[self participantViewWithUserID:self.callInfo.localParticipantId];
    if (!participantView) {
        CallParticipant *participant = [self.callInfo participantWithId:self.callInfo.localParticipantId];
        participantView = (ParticipantVideoView *)[self createParticipantVideoViewWithParticipant:participant];
        [self.bottomStackView addArrangedSubview:participantView];
    }
    participantView.videoView = videoView;
}

- (void)setupVideoTrack:(QBRTCVideoTrack *)videoTrack participantId:(NSNumber *)participantId {
    ParticipantVideoView *participantView = (ParticipantVideoView *)[self participantViewWithUserID:participantId];
    if (participantView) {
        QBRTCRemoteVideoView *remoteVideoView = (QBRTCRemoteVideoView *)participantView.videoView;
        if (remoteVideoView) {
            [remoteVideoView setVideoTrack:videoTrack];
        }
        participantView.videoContainerView.hidden = NO;
    }
}

- (void)setupConnectionState:(QBRTCConnectionState)connectionState participantId:(NSNumber *)participantId {
    ParticipantView *participantView = (ParticipantView *)[self participantViewWithUserID:participantId];
    if (!participantView) {
        return;
    }
    participantView.connectionState = connectionState;
}

- (void)setupVideoViewHidden:(BOOL)hidden participantId:(NSNumber *)userID {
    ParticipantVideoView *participantView = (ParticipantVideoView *)[self participantViewWithUserID:userID];
    if (!participantView || !participantView.videoView) {
        return;
    }
    participantView.videoContainerView.hidden = hidden;
}

- (void)setupVideoViewAnimation:(CATransition *)animation participantId:(NSNumber *)participantId {
    ParticipantVideoView *participantView = (ParticipantVideoView *)[self participantViewWithUserID:participantId];
    if (!participantView) {
        return;
    }
    UIView *videoView = participantView.videoView;
    if (!videoView) {
        return;
    }
    [videoView.superview.layer addAnimation:animation forKey:nil];
}

- (UIView *)participantViewWithUserID:(NSNumber *)participantId {
    NSArray<ParticipantVideoView *> *participantsViews = [self.topStackView.arrangedSubviews arrayByAddingObjectsFromArray:self.bottomStackView.arrangedSubviews];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"participantId == %@", participantId];
    return [participantsViews filteredArrayUsingPredicate:predicate].firstObject;;
}

//MARK: - Private Methods
- (UIView *)createParticipantVideoViewWithParticipant:(CallParticipant *)participant {
    ParticipantVideoView *participantView = [[NSBundle mainBundle] loadNibNamed:@"ParticipantVideoView"
                                                                          owner:nil
                                                                        options:nil].firstObject;
    [self setupParticipantView:participantView withParticipant:participant];
    participantView.nameLabel.hidden = participant.id == self.callInfo.localParticipantId;
    if (participant.id != self.callInfo.localParticipantId) {
        QBRTCRemoteVideoView *remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2, 2, 2, 2)];
        remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspect;
        participantView.videoView = remoteVideoView;
    }
    
    return participantView;
}

- (UIView *)createParticipantViewWithParticipant:(CallParticipant *)participant {
    ParticipantView *participantView = [[NSBundle mainBundle] loadNibNamed:@"ParticipantView"
                                                                     owner:nil
                                                                   options:nil].firstObject;
    [self setupParticipantView:participantView withParticipant:participant];
    return participantView;
}

- (void)setupParticipantView:(ParticipantView *)participantView withParticipant:(CallParticipant *)participant {
    participantView.name = participant.fullName;
    participantView.participantId = participant.id;
    if (participant.id == self.callInfo.localParticipantId) {
        participantView.isCallingInfo = NO;
    }
    else if (self.callInfo.direction == CallDirectionIncoming)  {
        participantView.isCallingInfo = NO;
        participantView.stateLabel.text = @"Calling...";
    }
    participantView.connectionState = participant.connectionState;
}

@end
