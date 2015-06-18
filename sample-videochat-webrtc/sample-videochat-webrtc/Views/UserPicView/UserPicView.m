//
//  UserPicView.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "UserPicView.h"

@implementation UserPicView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        
        [self setContentMode:UIViewContentModeRedraw];
        _picColor = [UIColor colorWithWhite:0.465 alpha:1.000];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawUserPicWithFrame:(CGRect)frame picColor:(UIColor *)picColor {
    
    CGFloat min = MIN(frame.size.height, frame.size.width) * 0.7;
    
    
    frame = CGRectMake(
                       CGRectGetMidX(self.bounds) - (min / 2.0),
                       CGRectGetMidY(self.bounds) - (min / 2.0),
                       min,
                       min);
    
    CGRect frame2 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.05844 + 0.5),
                               CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.06710 + 0.5),
                               floor(CGRectGetWidth(frame) * 0.94372 + 0.5) - floor(CGRectGetWidth(frame) * 0.05844 + 0.5),
                               floor(CGRectGetHeight(frame) * 0.93074 + 0.5) - floor(CGRectGetHeight(frame) * 0.06710 + 0.5));
    
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.71143 * CGRectGetWidth(frame2),
                                          CGRectGetMinY(frame2) + 0.52876 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.71143 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.09280 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.82887 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.40837 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.82887 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.21318 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.28613 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.09280 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.59398 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + -0.02759 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.40357 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + -0.02759 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.28613 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.52876 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.16868 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.21318 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.16868 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.40837 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.71143 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.52876 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.40357 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.64914 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.59398 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.64914 * CGRectGetHeight(frame2))];
    [bezier2Path closePath];
    
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.24886 * CGRectGetWidth(frame2),
                                          CGRectGetMinY(frame2) + 0.61372 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.25209 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61694 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.24993 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61480 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.25100 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61587 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.50611 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.70506 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.32405 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.68780 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.41422 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.70950 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.74914 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61694 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.58949 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.70104 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.67423 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.67719 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.75194 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61414 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.78850 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.58527 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.75101 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61508 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 1.00000 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 1.00000 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.90032 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.69161 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 1.00000 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.83541 * CGRectGetHeight(frame2))];
    
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.00000 * CGRectGetWidth(frame2),
                                             CGRectGetMinY(frame2) + 1.00000 * CGRectGetHeight(frame2))];
    
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.24886 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.61372 * CGRectGetHeight(frame2))
                   controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.00000 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.83511 * CGRectGetHeight(frame2))
                   controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.10004 * CGRectGetWidth(frame2),
                                              CGRectGetMinY(frame2) + 0.69109 * CGRectGetHeight(frame2))];
    
    [bezier2Path closePath];
    [picColor setFill];
    [bezier2Path fill];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [self drawUserPicWithFrame:self.bounds
                      picColor:self.picColor];
    // Drawing code
}

#pragma mark - setters

- (void)setPicColor:(UIColor *)picColor {
    
    if (![_picColor isEqual:picColor]) {
        _picColor = picColor;
        
        [self setNeedsDisplay];
    }
}

@end
