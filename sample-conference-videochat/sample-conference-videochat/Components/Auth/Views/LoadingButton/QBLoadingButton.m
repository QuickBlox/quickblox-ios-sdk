//
//  QBLoadingButton.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 01/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBLoadingButton.h"

@interface QBLoadingButton()

@property (strong, nonatomic, readonly) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) NSString *currentText;

@end

@implementation QBLoadingButton

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.shapeLayer.fillColor = [[UIColor colorWithRed:0.0392 green:0.3765 blue:1.0 alpha:1.0] CGColor];
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5] CGPath];
}

+ (Class)layerClass {
    
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    
    return (CAShapeLayer *)self.layer;
}

- (void)showLoading {
    
    if (self.activity) return;
//    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.fromValue = (__bridge id _Nullable)
    ([[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5] CGPath]);
    
    animation.repeatCount = 1;
    animation.duration = 0.15;
    
    CGFloat r = MIN(self.frame.size.height, self.frame.size.height);
    animation.toValue = (__bridge id)
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2 - r/2, 0, r, r)
                                cornerRadius:r] CGPath];
    
    [self.shapeLayer addAnimation:animation
                           forKey:@"shapeAnimation"];
    
    self.shapeLayer.path =
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2 - r/2, 0, r, r)
                                cornerRadius:r] CGPath];
    
    [self showAtivityIndicator];
    self.currentText = self.currentTitle;
    [self setTitle:@"" forState:UIControlStateNormal];

    UIColor *fromColor = [UIColor colorWithRed:0.0392 green:0.3765 blue:1.0 alpha:1.0];
    UIColor *toColor =  [UIColor colorWithRed:0.0802 green:0.616 blue:0.1214 alpha:1.0];
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    colorAnimation.repeatCount = NSIntegerMax;
    colorAnimation.duration = 1.0;
    colorAnimation.autoreverses = YES;
    
    [self.shapeLayer addAnimation:colorAnimation forKey:@"color"];
}

- (void)hideLoading {
    
    if (!self.activity) return;
    
    self.shapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5] CGPath];
    self.shapeLayer.fillColor = [[UIColor colorWithRed:0.0392 green:0.3765 blue:1.0 alpha:1.0] CGColor];
    
    [self hideActivityIndicator];
    [self setTitle:self.currentText forState:UIControlStateNormal];
    self.currentText = nil;
}

- (void)showAtivityIndicator {
    
    if (!self.activity) {
        
        self.userInteractionEnabled = NO;
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        [self.activity setHidden:NO];
        [self.activity startAnimating];
        [self.activity setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self addSubview:self.activity];
    }
}

- (void)hideActivityIndicator {
    
    self.userInteractionEnabled = YES;
    [self.shapeLayer removeAllAnimations];
    [self.activity removeFromSuperview];
    self.activity = nil;
}

- (void)setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        
        self.shapeLayer.fillColor = [[UIColor colorWithRed:0.0392 green:0.3765 blue:1.0 alpha:1.0] CGColor];
    }
    else {
        
        self.shapeLayer.fillColor = [[UIColor grayColor] CGColor];
    }
}

@end
