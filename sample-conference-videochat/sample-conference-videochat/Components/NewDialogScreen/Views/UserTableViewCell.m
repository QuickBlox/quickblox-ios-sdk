//
//  UserTableViewCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UserTableViewCell.h"
#import "UILabel+Chat.h"
#import "UIView+Chat.h"

@implementation UserTableViewCell
#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userAvatarImageView.hidden = YES;
    self.userAvatarLabel.hidden = NO;
    [self.userAvatarLabel setRoundedLabelWithCornerRadius:20.0f];
    self.contentView.backgroundColor = UIColor.clearColor;
    self.checkBoxView.backgroundColor = UIColor.clearColor;
    [self.checkBoxView setRoundBorderEdgeColorView:4.0f borderWidth:1.0f color:nil borderColor:[UIColor colorWithRed:0.42f green:0.48f blue:0.57f alpha:1.0f]];
    self.muteButton.hidden = YES;
    [self.muteButton setImage:[UIImage imageNamed:@"mute_opponent"] forState:UIControlStateNormal];
    [self.muteButton setImage:[UIImage imageNamed:@"unmute_opponent"] forState:UIControlStateSelected];
    self.muteButton.selected = NO;
}

#pragma mark - Setup
- (void)setUserColor:(UIColor *)userColor {
    _userColor = userColor;
    self.userAvatarLabel.backgroundColor = self.userColor;
}

- (IBAction)didTapMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.didPressMuteButton) {
        self.didPressMuteButton(sender.selected);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.isSelected) {
        self.checkBoxImageView.hidden = NO;
        self.contentView.backgroundColor = [UIColor colorWithRed:0.85f green:0.89f blue:0.97f alpha:1.0f];
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]
                                           borderColor:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]];
        
    } else {
        self.checkBoxImageView.hidden = YES;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:UIColor.clearColor
                                           borderColor:[UIColor colorWithRed:0.42f green:0.48f blue:0.57f alpha:1.0f]];
    }
    self.userAvatarLabel.backgroundColor = self.userColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.isHighlighted) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.85f green:0.89f blue:0.97f alpha:1.0f];
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]
                                           borderColor:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]];
        
    } else {
        self.contentView.backgroundColor = UIColor.clearColor;
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:UIColor.clearColor
                                           borderColor:[UIColor colorWithRed:0.42f green:0.48f blue:0.57f alpha:1.0f]];
    }
    self.userAvatarLabel.backgroundColor = self.userColor;
}

@end
