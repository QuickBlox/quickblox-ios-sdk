//
//  CheckMarkView.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CheckMarkView.h"

@implementation CheckMarkView

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawCheckMarkElementWithFrame:(CGRect)frame checked:(BOOL)checked {
    
    //// Color Declarations
    UIColor* clGray = [UIColor colorWithWhite:0.790 alpha:0.500];
    UIColor* clBlue = [UIColor colorWithRed: 0 green: 0.475 blue: 1 alpha: 1];
    UIColor* clWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Subframes
    CGRect elementGroup = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.03125 + 0.5),
                                     CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.02105 + 0.5),
                                     floor(CGRectGetWidth(frame) * 0.97917 + 0.5) - floor(CGRectGetWidth(frame) * 0.03125 + 0.5),
                                     floor(CGRectGetHeight(frame) * 0.97895 + 0.5) - floor(CGRectGetHeight(frame) * 0.02105 + 0.5));
    //// ElementGroup
    {
        if (checked)
            //// CheckGroupx5
        {
            //// checkBG Drawing
            UIBezierPath* checkBGPath = UIBezierPath.bezierPath;
            [checkBGPath moveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.82247 * CGRectGetWidth(elementGroup),
                                                  CGRectGetMinY(elementGroup) + 0.82247 * CGRectGetHeight(elementGroup))];
            
            [checkBGPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.82247 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.17753 * CGRectGetHeight(elementGroup))
                           controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 1.00057 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.64438 * CGRectGetHeight(elementGroup))
                           controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 1.00057 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.35562 * CGRectGetHeight(elementGroup))];
            
            [checkBGPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.17753 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.17753 * CGRectGetHeight(elementGroup))
                           controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.64438 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + -0.00057 * CGRectGetHeight(elementGroup))
                           controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.35562 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + -0.00057 * CGRectGetHeight(elementGroup))];
            
            [checkBGPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.17753 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.82247 * CGRectGetHeight(elementGroup))
                           controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + -0.00057 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.35562 * CGRectGetHeight(elementGroup))
                           controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + -0.00057 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.64438 * CGRectGetHeight(elementGroup))];
            
            [checkBGPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.82247 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 0.82247 * CGRectGetHeight(elementGroup))
                           controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.35562 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 1.00057 * CGRectGetHeight(elementGroup))
                           controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.64438 * CGRectGetWidth(elementGroup),
                                                      CGRectGetMinY(elementGroup) + 1.00057 * CGRectGetHeight(elementGroup))];
            
            [checkBGPath closePath];
            [clBlue setFill];
            [checkBGPath fill];
            
            //// check Drawing
            UIBezierPath* checkPath = UIBezierPath.bezierPath;
            [checkPath moveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.25917 * CGRectGetWidth(elementGroup),
                                                CGRectGetMinY(elementGroup) + 0.51537 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.44364 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.75108 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.74596 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.28479 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.68447 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.24380 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.44364 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.60761 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.31041 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.46413 * CGRectGetHeight(elementGroup))];
            
            [checkPath addLineToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.25917 * CGRectGetWidth(elementGroup),
                                                   CGRectGetMinY(elementGroup) + 0.51537 * CGRectGetHeight(elementGroup))];
            [checkPath closePath];
            [clWhite setFill];
            [checkPath fill];
        }
        
        if (!checked) {
            //// border Drawing
            UIBezierPath* borderPath = UIBezierPath.bezierPath;
            [borderPath moveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.20084 * CGRectGetWidth(elementGroup),
                                                 CGRectGetMinY(elementGroup) + 0.20084 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.20084 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.79916 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.03562 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.36606 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.03562 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.63394 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.79916 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.79916 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.36606 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.96438 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.63394 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.96438 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.79916 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.20084 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.96438 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.63394 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.96438 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.36606 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.20084 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.20084 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.63394 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.03562 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.36606 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.03562 * CGRectGetHeight(elementGroup))];
            [borderPath closePath];
            
            [borderPath moveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.85355 * CGRectGetWidth(elementGroup),
                                                 CGRectGetMinY(elementGroup) + 0.14645 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.85355 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.85355 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 1.04882 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.34171 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 1.04882 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.65829 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.14645 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.85355 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.65829 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 1.04882 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.34171 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 1.04882 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.14645 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.14645 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + -0.04882 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.65829 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + -0.04882 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.34171 * CGRectGetHeight(elementGroup))];
            
            [borderPath addCurveToPoint: CGPointMake(CGRectGetMinX(elementGroup) + 0.85355 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + 0.14645 * CGRectGetHeight(elementGroup))
                          controlPoint1: CGPointMake(CGRectGetMinX(elementGroup) + 0.34171 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + -0.04882 * CGRectGetHeight(elementGroup))
                          controlPoint2: CGPointMake(CGRectGetMinX(elementGroup) + 0.65829 * CGRectGetWidth(elementGroup),
                                                     CGRectGetMinY(elementGroup) + -0.04882 * CGRectGetHeight(elementGroup))];
            
            [borderPath closePath];
            
            [clGray setFill];
            [borderPath fill];
            
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [self drawCheckMarkElementWithFrame:self.bounds
                                checked:self.checked];
    // Drawing code
}

#pragma mark - Setters

- (void)setChecked:(BOOL)checked {
    
    if (_checked != checked) {
        _checked = checked;
        
        self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        
        if (_checked) {
            
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.transform = CGAffineTransformMakeScale(1.16f, 1.16f);
                
             } completion:^(BOOL finished) {
                 
                 if (finished) {
                     
                     [UIView animateWithDuration:0.08f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                         
                          self.transform = CGAffineTransformIdentity;
                         
                      } completion:nil];
                 }
             }];
        }
        else {
            
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                 self.transform = CGAffineTransformIdentity;
                
             } completion:nil];
        }

        [self setNeedsDisplay];
    }
}

@end
