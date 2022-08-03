//
//  StatsView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import "StatsView.h"
#import "CallParticipant.h"
#import "CallInfo.h"
#import "ActionsMenuView.h"
#import "MenuAction.h"

static NSString * const kStatsReportPlaceholderText = @"Loading stats report...";

@interface StatsView()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *statsLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *participantButton;
//MARK: - Properties
@property (strong, nonatomic) CallParticipant * _Nullable selectedParticipant;
@end


@implementation StatsView
//MARK - Setup
- (void)setCallInfo:(CallInfo *)callInfo {
    _callInfo = callInfo;
    self.selectedParticipant = self.callInfo.interlocutors.firstObject;
    
    __weak __typeof(self)weakSelf = self;
    [self.callInfo setOnChangedBitrate:^(NSNumber * _Nonnull ID, NSString * _Nonnull statsString) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (![strongSelf.selectedParticipant.id isEqual:ID]) {
            return;
        }
        [strongSelf updateStats:statsString];
    }];
}

- (void)setSelectedParticipant:(CallParticipant *)selectedParticipant {
    _selectedParticipant = selectedParticipant;
    NSString *title = [NSString stringWithFormat:@"%@ ⌵", selectedParticipant.fullName];
    [self.participantButton setTitle:title forState:UIControlStateNormal];
}

//MARK: - Actions
- (IBAction)didTapBack:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)didTapParticipant:(UIButton *)sender {
    ActionsMenuView *actionsMenuView = [[NSBundle mainBundle] loadNibNamed:@"ActionsMenuView" owner:nil options:nil].firstObject;
    for (CallParticipant *participant in self.callInfo.interlocutors) {
        participant.isSelected = [participant.id isEqual:self.selectedParticipant.id];
        __weak __typeof(self)weakSelf = self;
        MenuAction *selectParticipantAction = [[MenuAction alloc] initWithTitle:participant.fullName isSelected:participant.isSelected action:UserActionSelectParticipant handler:^(UserAction action) {
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.selectedParticipant.id isEqual:participant.id]) {
                return;
            }
            strongSelf.selectedParticipant = participant;
            [strongSelf updateStats:kStatsReportPlaceholderText];
        }];
        [actionsMenuView addAction:selectParticipantAction];
    }
    [self addSubview:actionsMenuView];
    actionsMenuView.translatesAutoresizingMaskIntoConstraints = NO;
    [actionsMenuView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [actionsMenuView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [actionsMenuView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant: -3.0f].active = YES;
    [actionsMenuView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
}

//MARK: - Private Methods
- (void)updateStats:(NSString *)stats {
    self.statsLabel.text = stats.length ? stats : kStatsReportPlaceholderText;
}

@end
