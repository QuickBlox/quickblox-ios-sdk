//
//  ChatGradientView.m
//  sample-conference-videochat
//
//  Created by Injoit on 13.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CallGradientView.h"

@interface CallGradientView()
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@end

@implementation CallGradientView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.startPoint = CGPointZero;
        [self applyGradient];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateGradientFrame];
}

//MARK: - Public Methods
- (void)setupGradientWithFirstColor:(UIColor *)firstColor andSecondColor:(UIColor *)secondColor {
    self.gradientLayer.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    [self applyGradient];
}


//MARK: - Internal Methods
- (void)applyGradient {
    [self updateGradientDirection];
    self.gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)updateGradientFrame {
    self.gradientLayer.frame = self.bounds;
}

- (void)updateGradientDirection {
    self.gradientLayer.endPoint = self.isVertical ? CGPointMake(0.0f, 1.0f) : CGPointMake(1.0f, 0.0f) ;
}

@end
