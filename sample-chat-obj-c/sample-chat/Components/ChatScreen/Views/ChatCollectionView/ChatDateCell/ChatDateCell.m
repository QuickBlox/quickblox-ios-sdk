//
//  ChatDateCell.m
//  sample-chat
//
//  Created by Injoit on 08.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ChatDateCell.h"
#import "UIView+Chat.h"

@implementation ChatDateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.dateBackgroundView setRoundViewWithCornerRadius:11.0f];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.dateLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.dateLabel.heightAnchor constraintEqualToConstant:15.0f].active = YES;
    [self.dateBackgroundView.topAnchor constraintEqualToAnchor:self.dateLabel.topAnchor constant:-3.0f].active = YES;
    [self.dateBackgroundView.leadingAnchor constraintEqualToAnchor:self.dateLabel.leadingAnchor constant:-16.0f].active = YES;
    [self.dateBackgroundView.bottomAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:3.0f].active = YES;
    [self.dateBackgroundView.trailingAnchor constraintEqualToAnchor:self.dateLabel.trailingAnchor constant:15.0f].active = YES;
}

+ (ChatCellLayoutModel)layoutModel {
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    defaultLayoutModel.avatarSize = CGSizeZero;
    defaultLayoutModel.topLabelHeight = 0.0f;
    defaultLayoutModel.timeLabelHeight = 0.0f;
    return defaultLayoutModel;
}

@end
