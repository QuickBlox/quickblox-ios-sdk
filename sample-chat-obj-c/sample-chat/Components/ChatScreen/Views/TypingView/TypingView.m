//
//  TypingView.m
//  samplechat
//
//  Created by Injoit on 2/11/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "TypingView.h"
#import "ChatManager.h"

NSString *const TYPING_ONE = @" is typing...";
NSString *const TYPING_TWO = @" are typing...";
NSString *const TYPING_FOUR = @" and 2 more are typing...";

@interface TypingView ()
@property (strong, nonatomic) ChatManager *chatManager;
@property (strong, nonatomic) UILabel *typingLabel;
@end

@implementation TypingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chatManager = [ChatManager instance];
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.98f alpha:1.0f];
    
    self.typingLabel = [[UILabel alloc] init];
    self.typingLabel.textColor = [UIColor colorWithRed:0.42f green:0.48f blue:0.57f alpha:1.0f];
    self.typingLabel.font = [UIFont italicSystemFontOfSize:13.0f];
    self.typingLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.typingLabel];
    self.typingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.typingLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:16.0f].active = YES;
    [self.typingLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-16.0f].active = YES;
    [self.typingLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.typingLabel.heightAnchor constraintEqualToConstant:15.0f].active = YES;
}

- (void)setupTypingViewWithOpponentUsersIDs:( NSSet * _Nullable )opponentUsersIDs {
    if (!opponentUsersIDs) {
        return;
    }
    NSString *typingString = @"";
    NSMutableArray *userNames = [NSMutableArray array];
    for (NSNumber *num in opponentUsersIDs) {
        QBUUser *opponentUser = [self.chatManager.storage userWithID:num.unsignedIntegerValue];
        if (opponentUser) {
            NSString *userName = opponentUser.fullName.length ? opponentUser.fullName : opponentUser.login;
            [userNames addObject:userName];
        } else {
            [userNames addObject:@"User"];
        }
    }

    
    switch (opponentUsersIDs.count) {
    case 1:
            typingString = [NSString stringWithFormat:@"%@%@", userNames.firstObject, TYPING_ONE];
            break;
    case 2:
            typingString = [NSString stringWithFormat:@"%@ and %@%@", userNames[0], userNames[1], TYPING_TWO];
            break;
    case 3:
            typingString = [NSString stringWithFormat:@"%@, %@, and %@%@", userNames[0], userNames[1], userNames[2], TYPING_TWO];
            break;
    default:
            typingString = [NSString stringWithFormat:@"%@, %@%@", userNames[0], userNames[1], TYPING_FOUR];
            break;
    }
    self.typingLabel.text = typingString;
}

@end
