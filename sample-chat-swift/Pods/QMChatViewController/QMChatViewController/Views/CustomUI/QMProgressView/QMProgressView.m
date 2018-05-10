//
//  QMProgressView.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/20/17.
//
//

#import "QMProgressView.h"

@interface QMProgressView()

@property (nonatomic, assign, readwrite) CGFloat progress;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) UIView *bar;

@end

@implementation QMProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initalSetup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self initalSetup];
    }
    
    return self;
}


#pragma mark - Intial Setup

- (void)initalSetup {

    self.bar = [UIView new];
    self.bar.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.progressBarColor != nil) {
        self.bar.backgroundColor = self.progressBarColor;
    }
    
    else {
        self.bar.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
    }
    
    self.bar.clipsToBounds = YES;
    
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.bar
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:CGRectGetWidth(self.frame) * self.progress];
    
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.bar
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0.0f];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.bar
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0f];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.bar
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0f];
    
    
    [self addSubview:self.bar];
    
    [self addConstraints:@[self.widthConstraint, left, top, bottom]];
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.0) progress = 1.0;
    
    if (_progress != progress) {
        _progress = progress;
    }
    _progress = MIN(1, progress);
    _widthConstraint.constant = CGRectGetWidth(self.bounds) * progress;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    
    self.progress = progress;
    CGFloat animationDuration = animated ? 0.1f : 0.0f;
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self layoutIfNeeded];
                     }];
}


@end
