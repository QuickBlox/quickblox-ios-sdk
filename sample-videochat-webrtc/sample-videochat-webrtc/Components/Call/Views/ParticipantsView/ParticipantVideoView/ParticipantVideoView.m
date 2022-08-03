//
//  ParticipantVideoView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "ParticipantVideoView.h"
#import "Profile.h"

@interface ParticipantVideoView()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *userNameTopLabel;
@end

@implementation ParticipantVideoView
//MARK - Setup
- (void)setupViews {
    [super setupViews];
    
    self.userNameTopLabel.hidden = YES;
}

- (void)setVideoView:(UIView *)videoView {
    _videoView = videoView;
    
    self.userNameTopLabel.hidden = NO;
    [self.videoContainerView insertSubview:videoView atIndex:0];
    self.videoContainerView.hidden = NO;
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [videoView.leftAnchor constraintEqualToAnchor:self.videoContainerView.leftAnchor].active = YES;
    [videoView.rightAnchor constraintEqualToAnchor:self.videoContainerView.rightAnchor].active = YES;
    [videoView.topAnchor constraintEqualToAnchor:self.videoContainerView.topAnchor].active = YES;
    [videoView.bottomAnchor constraintEqualToAnchor:self.videoContainerView.bottomAnchor].active = YES;
    [videoView layoutIfNeeded];
}

- (void)setName:(NSString *)name {
    [super setName:name];
    
    self.userNameTopLabel.text = self.name;
}

- (void)setParticipantId:(NSNumber *)userID {
    [super setParticipantId:userID];
    Profile *profile = [[Profile alloc] init];
    if (profile.ID == userID.unsignedIntValue) {
        self.userNameTopLabel.text = @"You";
    }
}

- (void)setupHiddenViews {
    self.callingInfoLabelHeightConstraint.constant = 0.0f;
    self.stateLabel.hidden = NO;
    self.videoContainerView.hidden = YES;
}

@end
