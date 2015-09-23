//
//  QMLoadEarlierHeaderView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMLoadEarlierHeaderView.h"

const CGFloat kQMLoadEarlierHeaderViewHeight = 32.0f;

@interface QMLoadEarlierHeaderView ()

@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@end

@implementation QMLoadEarlierHeaderView

#pragma mark - Class methods

+ (UINib *)nib {
    
    return [UINib nibWithNibName:NSStringFromClass([QMLoadEarlierHeaderView class])
                          bundle:[NSBundle bundleForClass:[QMLoadEarlierHeaderView class]]];
}

+ (NSString *)headerReuseIdentifier {
    
    return NSStringFromClass([QMLoadEarlierHeaderView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.loadButton setTitle:@"Load earlier messages" forState:UIControlStateNormal];
    self.loadButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)dealloc {
    
    _loadButton = nil;
    _delegate = nil;
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [super setBackgroundColor:backgroundColor];
    self.loadButton.backgroundColor = backgroundColor;
}

#pragma mark - Actions

- (IBAction)loadButtonPressed:(UIButton *)sender {
    
    [self.delegate headerView:self didPressLoadButton:sender];
}

@end
