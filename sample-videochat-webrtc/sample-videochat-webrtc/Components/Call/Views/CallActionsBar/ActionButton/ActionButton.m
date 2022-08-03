//
//  Button.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ActionButton.h"

@import QuartzCore;

@interface ActionButton()
//MARK: - Properties
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIView *backgroundSelectedView;
@property (strong, nonatomic) UILabel *actionButtonLabel;
@property (nonatomic, strong) UIColor *textColor;
@end

@implementation ActionButton
//MARK: - Life Cycle
- (void)commonInit {
    self.pressed = NO;
    self.pushed = NO;
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    self.backgroundColor = UIColor.clearColor;
    self.textColor = [UIColor whiteColor];
    
    self.selectedView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.alpha = 0.0f;
        view.userInteractionEnabled = NO;
        view;
    });
    
    self.backgroundSelectedView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.alpha = 1.0f;
        view.userInteractionEnabled = NO;
        view;
    });
    
    self.actionButtonLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = UIColor.whiteColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10.0f];
        label;
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self performLayout];
}

//MARK - Setup
- (void)performLayout {
    CGFloat width = 56.0f;
    CGFloat maxFrame = width / 2.0f;
    
    [self addSubview:self.backgroundSelectedView];
    self.backgroundSelectedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundSelectedView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.backgroundSelectedView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.backgroundSelectedView.heightAnchor constraintEqualToConstant:width].active = YES;
    [self.backgroundSelectedView.widthAnchor constraintEqualToConstant:width].active = YES;
    self.backgroundSelectedView.layer.cornerRadius = maxFrame;
    
    [self addSubview:self.selectedView];
    self.selectedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectedView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.selectedView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.selectedView.heightAnchor constraintEqualToConstant:width].active = YES;
    [self.selectedView.widthAnchor constraintEqualToConstant:width].active = YES;
    self.selectedView.layer.cornerRadius = maxFrame;
    
    [self addSubview:self.iconView];
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.leftAnchor constraintEqualToAnchor:self.selectedView.leftAnchor].active = YES;
    [self.iconView.topAnchor constraintEqualToAnchor:self.selectedView.topAnchor].active = YES;
    [self.iconView.rightAnchor constraintEqualToAnchor:self.selectedView.rightAnchor].active = YES;
    [self.iconView.bottomAnchor constraintEqualToAnchor:self.selectedView.bottomAnchor].active = YES;

    [self addSubview:self.actionButtonLabel];
    self.actionButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionButtonLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.actionButtonLabel.topAnchor constraintEqualToAnchor:self.selectedView.bottomAnchor constant: 8.0f].active = YES;
    [self.actionButtonLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.actionButtonLabel.heightAnchor constraintEqualToConstant:12.0f].active = YES;
}

//MARK: - Private Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    self.highlighted = YES;
    self.selectedView.alpha = 1;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if (self.pushed) {
        self.pressed = !self.pressed;
        self.highlighted = self.pressed;
    } else {
        self.selectedView.alpha = 1.0f;
        self.highlighted = self.pressed;
    }
}

#pragma mark - Default View Methods
- (UILabel *)standardLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 1.0;
    
    return label;
}

#pragma mark - Setters
- (void)setIconView:(UIImageView *)iconView {
    if (![_iconView isEqual:iconView]) {
        iconView.userInteractionEnabled = NO;
        _iconView = iconView;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
    _selectedTitle = selectedTitle;
}

- (void)setUnSelectedTitle:(NSString *)unSelectedTitle {
    _unSelectedTitle = unSelectedTitle;
    self.actionButtonLabel.text = unSelectedTitle;
}

- (void)setPressed:(BOOL)pressed {
    _pressed = pressed;
    self.highlighted = _pressed;
    self.selectedView.alpha = _pressed ? 1.0f : 0.0f;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self.iconView setHighlighted:highlighted];
    self.actionButtonLabel.text = highlighted ? self.selectedTitle : self.unSelectedTitle;
}

@end
