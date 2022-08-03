//
//  ChatGradientView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 13.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CallGradientView.h"

@interface CallGradientView()
//MARK: - Properties
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@end

@implementation CallGradientView
//MARK: - Life Cycle
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.startPoint = CGPointZero;
        self.gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
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
    self.gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)updateGradientFrame {
    self.gradientLayer.frame = self.bounds;
}

@end
