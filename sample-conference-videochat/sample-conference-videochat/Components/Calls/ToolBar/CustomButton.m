//
//  IAButton.m
//  sample-conference-videochat
//
//  Created by Injoit on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CustomButton.h"

@import QuartzCore;

const CGFloat kAnimationLength = 0.15;

@interface CustomButton()

@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIView *backgroundSelectedView;
@property (strong, nonatomic) UILabel *actionButtonLabel;

@end

@implementation CustomButton

- (void)commonInit {
    self.pressed = NO;
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    self.backgroundColor = UIColor.clearColor;
    self.borderColor = [UIColor colorWithWhite:0.352 alpha:0.560];
    self.selectedColor = [UIColor colorWithWhite:1.000 alpha:0.600];
    self.textColor = [UIColor whiteColor];
    
    self.selectedView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.alpha = 0.0f;
        view.backgroundColor = self.selectedColor;
        view.userInteractionEnabled = NO;
        view;
    });
    
    self.backgroundSelectedView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.alpha = 1.0f;
        view.backgroundColor = self.unSelectedColor;
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

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self prepareApperance];
    [self performLayout];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self prepareApperance];
}

- (void)prepareApperance {
    self.selectedView.backgroundColor = self.selectedColor;
    self.backgroundSelectedView.backgroundColor = self.unSelectedColor;
    self.layer.borderColor = [self.borderColor CGColor];
}

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
    [self.iconView.centerXAnchor constraintEqualToAnchor:self.selectedView.centerXAnchor].active = YES;
    [self.iconView.centerYAnchor constraintEqualToAnchor:self.selectedView.centerYAnchor].active = YES;
    [self.iconView.heightAnchor constraintEqualToConstant:maxFrame].active = YES;
    [self.iconView.widthAnchor constraintEqualToConstant:maxFrame].active = YES;
    
    [self addSubview:self.actionButtonLabel];
    self.actionButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionButtonLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.actionButtonLabel.topAnchor constraintEqualToAnchor:self.selectedView.bottomAnchor constant: 8.0f].active = YES;
    [self.actionButtonLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.actionButtonLabel.heightAnchor constraintEqualToConstant:12.0f].active = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
        weakSelf.highlighted = YES;
        weakSelf.selectedView.alpha = 1;
        
    } completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
        
        if (weakSelf.isPushed == YES) {
            weakSelf.pressed = !weakSelf.pressed;
            weakSelf.highlighted = weakSelf.pressed;
        } else {
            weakSelf.selectedView.alpha = 1.0f;
            weakSelf.highlighted = weakSelf.pressed;
        }
        
    } completion:nil];
}

- (void)setUnSelectedColor:(UIColor *)unSelectedColor {
    _unSelectedColor = unSelectedColor;
    self.backgroundSelectedView.backgroundColor = unSelectedColor;
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
    self.selectedView.alpha = _pressed ? 1.0f : 0.0F;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self.iconView setHighlighted:highlighted];
    self.actionButtonLabel.text = highlighted ? self.selectedTitle : self.unSelectedTitle;
}

#pragma mark -
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

@end
