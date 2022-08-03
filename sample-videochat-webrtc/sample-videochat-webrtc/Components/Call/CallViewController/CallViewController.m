//
//  CallViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CallViewController.h"
#import "StatsView.h"
#import "CallAction.h"
#import "ActionButton.h"

@interface CallViewController()
//MARK: - Properties
@property (strong, nonatomic) StatsView *statsView;

@end

@implementation CallViewController
//MARK - Setup
- (void)setupWithCallId:(NSString *)callId
                members:(NSDictionary<NSNumber *, NSString *>*)members
          mediaListener:(MediaListener *)mediaListener
        mediaController:(MediaController *)mediaController
              direction:(CallDirection)direction {
    self.callInfo = [CallInfo callInfoWithCallID:callId  members:members direction:direction];
    self.mediaListener = mediaListener;
    self.mediaController = mediaController;
    
    __weak __typeof(self)weakSelf = self;
    [self.mediaListener setOnAudio:^(BOOL enabled) {
        [weakSelf.actionsBar select:!enabled type:CallActionAudio];
    }];
}

- (void)endCall {
    [self.actionsBar clear];
    [self.mediaController clear];
    [self.callInfo clear];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkCallPermissionsWithConferenceType:QBRTCConferenceTypeAudio completion:nil];
    
    __weak __typeof(self)weakSelf = self;
    NSMutableArray *callActions = @[].mutableCopy;
    
    [callActions addObject:[[CallAction alloc] initWithType:CallActionAudio action:^(ActionButton * _Nonnull sender) {
        weakSelf.mediaController.audioEnabled = !weakSelf.mediaController.audioEnabled;
    }]];
    [callActions addObject:[[CallAction alloc] initWithType:CallActionDecline action:^(ActionButton * _Nonnull sender) {
        sender.enabled = NO;
        if (weakSelf.hangUp) {
            weakSelf.hangUp(weakSelf.callInfo.callId);
        }
    }]];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [callActions addObject:[[CallAction alloc] initWithType:CallActionSpeaker action:^(ActionButton * _Nonnull sender) {
            weakSelf.mediaController.currentAudioOutput = sender.pressed ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
        }]];
    }
    [self.actionsBar setupWithActions:callActions.copy];
    BOOL selectedState = self.mediaController.currentAudioOutput == AVAudioSessionPortOverrideSpeaker;
    [self.actionsBar select:selectedState type:CallActionSpeaker];
    [self.actionsBar select:!self.mediaController.audioEnabled type:CallActionAudio];
    
    [self.participantsView setupWithCallInfo:self.callInfo conferenceType:QBRTCConferenceTypeAudio];
    
    
    [self.callInfo setOnChangedState:^(CallParticipant * _Nonnull participant) {
        [weakSelf.participantsView setupConnectionState: participant.connectionState participantId:participant.id];
        
        if (weakSelf.callTimer.isActive == NO && participant.connectionState == QBRTCConnectionStateConnected) {
            weakSelf.callTimer.isActive = YES;
            weakSelf.statsButton.enabled = YES;
            weakSelf.statsButton.alpha = 1.0f;
            
            if (weakSelf.callInfo.direction == CallDirectionOutgoing) {
                BOOL isPressed = [weakSelf.actionsBar isSelected:CallActionSpeaker];
                AVAudioSessionPortOverride audioPort =
                isPressed ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
                QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
                [audioSession overrideOutputAudioPort:audioPort];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

//MARK: - Public Methods
- (IBAction)didTapStatsButton:(UIButton *)sender {
    self.statsView = [[NSBundle mainBundle] loadNibNamed:@"StatsView" owner:nil options:nil].firstObject;
    self.statsView.callInfo = self.callInfo;
    [self.view addSubview:self.statsView];
    self.statsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.statsView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.statsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant: -3.0f].active = YES;
    [self.statsView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

- (void)checkCallPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(СheckPermissionsCompletion _Nullable)completion {
    __weak __typeof(self)weakSelf = self;
    [CallPermissions checkPermissionsWithConferenceType:QBRTCConferenceTypeAudio presentingViewController:self completion:^(BOOL granted) {
        if (granted == NO) {
            [weakSelf.actionsBar select:YES type:CallActionAudio];
            [weakSelf.actionsBar setUserInteractionEnabled:NO type:CallActionAudio];
            weakSelf.mediaController.audioEnabled = NO;
        }
        if (conferenceType == QBRTCConferenceTypeAudio) {
            if (completion) {
                completion(granted);
            }
            return;
        }
    }];
    
    if (conferenceType == QBRTCConferenceTypeVideo) {
        [CallPermissions checkPermissionsWithConferenceType:QBRTCConferenceTypeVideo
                                   presentingViewController:self completion:^(BOOL granted) {
            if (granted == NO) {
                [weakSelf.actionsBar select:YES type:CallActionVideo];
                [weakSelf.actionsBar select:YES type:CallActionSwitchCamera];
                [weakSelf.actionsBar setUserInteractionEnabled:NO type:CallActionVideo];
                [weakSelf.actionsBar setUserInteractionEnabled:NO type:CallActionSwitchCamera];
            }
            weakSelf.mediaController.videoEnabled = granted;
            if (completion) {
                completion(granted);
            }
        }];
    }
}

@end
