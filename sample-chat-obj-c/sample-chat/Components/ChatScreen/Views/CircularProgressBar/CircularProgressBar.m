//
//  CircularProgressBar.m
//  sample-chat
//
//  Created by Injoit on 2/7/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CircularProgressBar.h"

@interface CircularProgressBar()
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@end

@implementation CircularProgressBar

- (void)awakeFromNib {
    [super awakeFromNib];

    self.shapeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:25.0f startAngle:0.0f endAngle:2*M_PI clockwise:YES];
    self.shapeLayer.path = circularPath.CGPath;
    UIColor *appColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    self.shapeLayer.strokeColor = appColor.CGColor;
    self.shapeLayer.lineWidth = 6.0f;
    self.shapeLayer.fillColor = UIColor.clearColor.CGColor;
    [self.shapeLayer setLineCap:kCALineCapRound];
    self.shapeLayer.position = [self convertPoint:self.center fromView:self.superview];
    self.shapeLayer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
    self.shapeLayer.strokeEnd = 0;
    [self.layer insertSublayer:self.shapeLayer atIndex:0];
}

//MARK: Public
- (void)setProgressTo:(CGFloat)progressConstant {
    if (progressConstant > self.shapeLayer.strokeEnd) {
        self.shapeLayer.strokeEnd = progressConstant;
    }
}

@end
