//
//  VideoCallViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "VideoCallViewController.h"
#import "CallPermissions.h"
#import "LocalVideoView.h"
#import "CallAction.h"
#import "SharingViewController.h"
#import "ActionButton.h"

@interface VideoCallViewController ()
@end

@implementation VideoCallViewController
//MARK: - Life Cycle
- (void)setupWithCallId:(NSString *)callId
                members:(NSDictionary<NSNumber *, NSString *>*)members
          mediaListener:(MediaListener *)mediaListener
        mediaController:(MediaController *)mediaController
              direction:(CallDirection)direction {
    
    [super setupWithCallId:callId
                   members:members
             mediaListener:mediaListener
           mediaController:mediaController
                 direction:direction];
    
    __weak __typeof(self)weakSelf = self;
    [self.callInfo setOnChangedState:^(CallParticipant * _Nonnull participant) {
        [weakSelf.participantsView setupConnectionState: participant.connectionState participantId:participant.id];
        
        if (participant.connectionState != QBRTCConnectionStateConnected) {
            return;
        }
        
        if (weakSelf.callTimer.isActive != YES) {
            weakSelf.callTimer.isActive = YES;
            weakSelf.statsButton.enabled = YES;
            weakSelf.statsButton.alpha = 1.0f;
            
            if (weakSelf.callInfo.direction == CallDirectionOutgoing) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf setupCallScreen];
                });
            }
        }
        
        QBRTCVideoTrack *videoTrack = [weakSelf.mediaController videoTrackForUserID:participant.id];
        if (videoTrack) {
            [weakSelf.participantsView setupVideoTrack:videoTrack participantId:participant.id];
        }
    }];
    
    [self.mediaListener setOnVideo:^(BOOL enabled) {
        [weakSelf.actionsBar select:!enabled type:CallActionVideo];
    }];
    
    [self.mediaListener setOnSharing:^(BOOL enabled) {
        [weakSelf.actionsBar select:!enabled type:CallActionShare];
    }];
}

- (void)viewDidLoad {
    [self.participantsView setupWithCallInfo:self.callInfo conferenceType:QBRTCConferenceTypeVideo];
    __weak __typeof(self)weakSelf = self;
    [self checkCallPermissionsWithConferenceType:QBRTCConferenceTypeVideo completion:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.callInfo.direction == CallDirectionIncoming ? [weakSelf setupCallScreen] : [weakSelf setupCallingScreen];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.actionsBar select:NO type:CallActionShare];
}

//MARK: - Private Methods
- (void)cameraEnable:(BOOL)enable {
    if (!self.mediaController.camera.hasStarted && enable) {
        [self.mediaController.camera startSession:nil];
    }
    [self.participantsView setupVideoViewHidden:!enable participantId:self.callInfo.localParticipantId];
    [self.actionsBar setUserInteractionEnabled:enable type:CallActionSwitchCamera];
}

//MARK - Setup
- (void)setupCallScreen {
    [self.bottomView setupGradientWithFirstColor:[UIColor.blackColor colorWithAlphaComponent:0.0f]
                                  andSecondColor:[UIColor.blackColor colorWithAlphaComponent:0.7f]];
    [self.headerView setupGradientWithFirstColor:[UIColor.blackColor colorWithAlphaComponent:0.7f]
                                  andSecondColor:[UIColor.blackColor colorWithAlphaComponent:0.0f]];
    
    
    __weak __typeof(self)weakSelf = self;
    [self.actionsBar setupWithActions:@[
        [[CallAction alloc] initWithType:CallActionAudio action:^(ActionButton * _Nonnull sender) {
        weakSelf.mediaController.audioEnabled = !weakSelf.mediaController.audioEnabled;
    }],
        [[CallAction alloc] initWithType:CallActionVideo action:^(ActionButton * _Nonnull sender) {
        weakSelf.mediaController.videoEnabled = !weakSelf.mediaController.videoEnabled;
        [weakSelf cameraEnable:weakSelf.mediaController.videoEnabled];
    }],
        [[CallAction alloc] initWithType:CallActionDecline action:^(ActionButton * _Nonnull sender) {
        sender.enabled = NO;
        if (weakSelf.hangUp) {
            weakSelf.hangUp(weakSelf.callInfo.callId);
        }
    }],
        [[CallAction alloc] initWithType:CallActionShare action:^(ActionButton * _Nonnull sender) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Call" bundle:nil];
        SharingViewController *sharingVC =
        [storyboard instantiateViewControllerWithIdentifier:@"SharingViewController"];
        sharingVC.mediaController = self.mediaController;
        [weakSelf.navigationController pushViewController:sharingVC animated:NO];
    }],
        [[CallAction alloc] initWithType:CallActionSwitchCamera action:^(ActionButton * _Nonnull sender) {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.75f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        animation.subtype = weakSelf.mediaController.camera.position == AVCaptureDevicePositionBack ? kCATransitionFromLeft : kCATransitionFromRight;
        [weakSelf.participantsView setupVideoViewAnimation:animation participantId:weakSelf.callInfo.localParticipantId];
        
        AVCaptureDevicePosition position = self.mediaController.camera.position ==
        AVCaptureDevicePositionBack ?
        AVCaptureDevicePositionFront :
        AVCaptureDevicePositionBack;
        
        if ([self.mediaController.camera hasCameraForPosition:position] == NO) {
            return;
        }
        self.mediaController.camera.position = position;
    }]
    ]];
    [self.actionsBar select:!self.mediaController.audioEnabled type:CallActionAudio];
    [self.actionsBar select:NO type:CallActionShare];
    LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewlayer:self.mediaController.camera.previewLayer];
    [self.participantsView addLocalVideo:localVideoView];
    if (self.mediaController.videoEnabled == YES) {
        [self cameraEnable:YES];
    }
    
    for (CallParticipant *participant in self.callInfo.interlocutors) {
        QBRTCVideoTrack *videoTrack = [self.mediaController videoTrackForUserID:participant.id];
        if (videoTrack) {
            [weakSelf.participantsView setupVideoTrack:videoTrack participantId:participant.id];
        }
    }
    
    [self.mediaListener setOnReceivedRemoteVideoTrack:^(QBRTCVideoTrack * _Nonnull videoTrack, NSNumber * _Nonnull userID) {
        [weakSelf.participantsView setupVideoTrack:videoTrack participantId:userID];
    }];
}

- (void)setupCallingScreen {
    __weak __typeof(self)weakSelf = self;
    [self.actionsBar setupWithActions:@[
        [[CallAction alloc] initWithType:CallActionAudio action:^(ActionButton * _Nonnull sender) {
        weakSelf.mediaController.audioEnabled = !weakSelf.mediaController.audioEnabled;
    }],
        [[CallAction alloc] initWithType:CallActionDecline action:^(ActionButton * _Nonnull sender) {
        sender.enabled = NO;
        if (weakSelf.hangUp) {
            weakSelf.hangUp(weakSelf.callInfo.callId);
        }
    }],
        [[CallAction alloc] initWithType:CallActionVideo action:^(ActionButton * _Nonnull sender) {
        weakSelf.mediaController.videoEnabled = !weakSelf.mediaController.videoEnabled;
        [weakSelf cameraEnable:weakSelf.mediaController.videoEnabled];
    }]
    ]];
}

@end
