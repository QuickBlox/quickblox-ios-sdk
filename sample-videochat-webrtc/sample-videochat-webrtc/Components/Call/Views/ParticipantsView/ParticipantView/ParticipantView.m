//
//  ParticipantView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "ParticipantView.h"
#import "UILabel+Videochat.h"
#import "UIView+Videochat.h"
#import "NSString+Videochat.h"
#import "UIColor+Videochat.h"

@interface ParticipantView()
@end

@implementation ParticipantView
//MARK: - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];

    [self setupViews];
}

//MARK - Setup
- (void)setupViews {
    self.backgroundColor = UIColor.clearColor;
    self.containerView.backgroundColor = [UIColor colorWithRed:0.20f green:0.20f blue:0.20f alpha:1.0f];
    [self.userAvatarLabel setRoundedLabelWithCornerRadius:30.0f];
    [self.userAvatarImageView setRoundViewWithCornerRadius:30.0f];
    self.userAvatarImageView.hidden = YES;
    self.nameLabelCenterXConstraint.constant = 0.0f;
    self.callingInfoLabelHeightConstraint.constant = 28.0f;
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = self.name;
    self.userAvatarLabel.text = name.firstLetter;
}

- (void)setParticipantId:(NSNumber *)userID {
    _participantId = userID;
    self.userAvatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                            (unsigned long)self.participantId.unsignedIntValue]];
}

- (void)setIsCallingInfo:(BOOL)isCallingInfo {
    _isCallingInfo = isCallingInfo;
    if (_isCallingInfo == NO) {
        self.callingInfoLabelHeightConstraint.constant = 0.0f;
    } else {
        self.callingInfoLabelHeightConstraint.constant = 28.0f;
    }
}

- (void)setConnectionState:(QBRTCConnectionState)connectionState {
    
    if (_connectionState != connectionState) {
        _connectionState = connectionState;
        
        switch (connectionState) {
            case QBRTCConnectionStateConnected:
                self.stateLabel.text = @"";
                self.callingInfoLabelHeightConstraint.constant = 0.0f;
                self.stateLabel.hidden = YES;
                break;

            case QBRTCConnectionStateClosed:
                self.stateLabel.text = @"Closed";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateFailed:
                self.stateLabel.text = @"Failed";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateHangUp:
                self.stateLabel.text = @"Hung Up";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateRejected:
                self.stateLabel.text = @"Rejected";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateNoAnswer:
                self.stateLabel.text = @"No Answer";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateDisconnectTimeout:
                self.stateLabel.text = @"Time out";
                [self setupHiddenViews];
                break;

            case QBRTCConnectionStateDisconnected:
                self.stateLabel.text = @"Disconnected";
                [self setupHiddenViews];
                break;

            default:
                self.stateLabel.text = @"";
                break;
        }
    }
}

- (void)setupHiddenViews {
    self.callingInfoLabelHeightConstraint.constant = 0.0f;
    self.stateLabel.hidden = NO;
}

@end
