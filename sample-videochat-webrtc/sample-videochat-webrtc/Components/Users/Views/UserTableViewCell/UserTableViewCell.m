//
//  UserTableViewCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UserTableViewCell.h"
#import "UILabel+Videochat.h"
#import "UIView+Videochat.h"
#import "NSString+Videochat.h"
#import "UIColor+Videochat.h"

@interface UserTableViewCell ()
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userAvatarLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) UIColor *userColor;
@end

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
- (void)setupUserID:(NSUInteger)userID {
    self.userColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                  (unsigned long)userID]];
    self.userAvatarLabel.backgroundColor = self.userColor;
}

- (void)setupUserName:(NSString *)userName {
    self.userNameLabel.text = userName;
    self.userAvatarLabel.text = userName.firstLetter;
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
