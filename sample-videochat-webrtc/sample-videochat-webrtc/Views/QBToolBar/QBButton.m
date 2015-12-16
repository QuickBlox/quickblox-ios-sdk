//
//  IAButton.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "QBButton.h"

@import QuartzCore;

const CGFloat kAnimationLength = 0.15;

@interface QBButton()

@property (nonatomic, strong) UIView *selectedView;

@end

@implementation QBButton

- (void)commonInit {
    
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    self.backgroundColor = nil;

    [self setDefaultStyles];
    
    self.clipsToBounds = YES;
    
    self.selectedView = ({
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.alpha = 0.0f;
        view.backgroundColor = self.selectedColor;
        view.userInteractionEnabled = NO;
        
        view;
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

- (void)setDefaultStyles {
    
    self.borderColor = [UIColor colorWithWhite:0.352 alpha:0.560];
    self.selectedColor = [UIColor colorWithWhite:1.000 alpha:0.600];
    self.textColor = [UIColor whiteColor];
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
    self.layer.borderColor = [self.borderColor CGColor];
}

- (void)performLayout {
    
    self.selectedView.frame = CGRectMake(0,
                                         0,
                                         self.frame.size.width,
                                         self.frame.size.height);
    
    
    [self addSubview:self.selectedView];
    
    CGFloat max = MAX(self.frame.size.height, self.frame.size.width) * 0.5;
    self.iconView.frame = CGRectMake(
                                     CGRectGetMidX(self.bounds) - (max / 2.0),
                                     CGRectGetMidY(self.bounds) - (max / 2.0),
                                     max,
                                     max);
    [self addSubview:self.iconView];
    
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
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
         
         if (self.isPushed) {
             
            self.pressed ^= YES;
        

         }
         else {
             
             [weakSelf setHighlighted:NO];
             weakSelf.selectedView.alpha = 0;
         }
         
     } completion:nil];
}

- (void)setPressed:(BOOL)pressed {
    
    _pressed = pressed;
    self.highlighted = _pressed;
    self.selectedView.alpha = _pressed;
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
    [self.iconView setHighlighted:highlighted];
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
