//
//  ChatPrivateTitleView.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/11/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ChatPrivateTitleView.h"
#import "UIColor+Chat.h"
#import "UIView+Chat.h"

@interface ChatPrivateTitleView ()
@property (strong, nonatomic) UILabel *avatarLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ChatPrivateTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.avatarLabel = [[UILabel alloc] init];
    self.avatarLabel.backgroundColor = [UIColor colorWithRed:0.56f green:0.35f blue:0.97f alpha:1.0f];
    self.avatarLabel.textColor = UIColor.whiteColor;
    self.avatarLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    self.avatarLabel.textAlignment = NSTextAlignmentCenter;
    [self.avatarLabel setRoundViewWithCornerRadius:13.0f];
    self.avatarLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.avatarLabel.widthAnchor constraintEqualToConstant:26.0f].active = YES;
    [self.avatarLabel.heightAnchor constraintEqualToConstant:26.0f].active = YES;
    
    self.avatarImageView = [[UIImageView alloc] init];
    [self.avatarImageView setRoundViewWithCornerRadius:13.0f];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarLabel addSubview:self.avatarImageView];
    self.avatarImageView.center = self.avatarLabel.center;
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.avatarImageView.widthAnchor constraintEqualToConstant:26.0f].active = YES;
    [self.avatarImageView.heightAnchor constraintEqualToConstant:26.0f].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [self addSubview:self.titleLabel];
    
}

- (void)setupPrivateChatTitleViewWithOpponentUser:(QBUUser *)opponentUser {
    NSString *userName = opponentUser.fullName.length ? opponentUser.fullName : opponentUser.login;
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [userName stringByTrimmingCharactersInSet:characterSet];
    NSString *firstLetter = [name substringToIndex:1];
    self.avatarLabel.text = [firstLetter uppercaseString];
    self.avatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
    (unsigned long)opponentUser.ID]];
    self.titleLabel.text = userName;
    [self addArrangedSubview:self.avatarLabel];
    [self addArrangedSubview:self.titleLabel];
    self.spacing = 5.0f;
    self.alignment = UIStackViewAlignmentCenter;
}

@end
