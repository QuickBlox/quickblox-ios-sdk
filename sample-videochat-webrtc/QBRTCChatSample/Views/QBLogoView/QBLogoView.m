//
//  QBLogoView.m
//  QBRTCChatSemple
//
//  Created by Andrey on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "QBLogoView.h"

@implementation QBLogoView

- (void)drawQBLogoWithFrame: (CGRect)frame;
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* grColor_b = [UIColor colorWithRed: 0.29 green: 0.643 blue: 0.847 alpha: 1];
    UIColor* grColor_b_l = [UIColor colorWithRed: 0.29 green: 0.643 blue: 0.847 alpha: 1];
    UIColor* grColor_g = [UIColor colorWithRed: 0.514 green: 0.741 blue: 0.259 alpha: 1];
    UIColor* grColor_g_l = [UIColor colorWithRed: 0.934 green: 1 blue: 0.216 alpha: 1];
    UIColor* grColor_b_d = [UIColor colorWithRed: 0.11 green: 0.459 blue: 0.725 alpha: 1];
    UIColor* gradient3Color2 = [UIColor colorWithRed: 0.149 green: 0.49 blue: 0.761 alpha: 1];
    
    //// Gradient Declarations
    CGFloat gr_b_lLocations[] = {0, 0.42, 1};
    CGGradientRef gr_b_l = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)grColor_b_l.CGColor, (id)[UIColor colorWithRed: 0.29 green: 0.643 blue: 0.847 alpha: 1].CGColor, (id)grColor_b.CGColor], gr_b_lLocations);
    CGFloat gr_gLocations[] = {0, 1};
    CGGradientRef gr_g = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)grColor_g_l.CGColor, (id)grColor_g.CGColor], gr_gLocations);
    CGFloat gr_bLocations[] = {0, 1};
    CGGradientRef gr_b = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)grColor_b_d.CGColor, (id)gradient3Color2.CGColor], gr_bLocations);
    
    //// Variable Declarations
    CGFloat cornerRadius = 1 + 2;
    
    //// r1 Drawing
    UIBezierPath* r1Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00962 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.02857 + 0.5), floor(CGRectGetWidth(frame) * 0.25000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00962 + 0.5), floor(CGRectGetHeight(frame) * 0.25714 + 0.5) - floor(CGRectGetHeight(frame) * 0.02857 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r1Path addClip];
    UIBezierPath* r1RotatedPath = [r1Path copy];
    CGAffineTransform r1Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r1RotatedPath applyTransform: r1Transform];
    CGRect r1Bounds = CGPathGetPathBoundingBox(r1RotatedPath.CGPath);
    r1Transform = CGAffineTransformInvert(r1Transform);
    
    CGContextDrawLinearGradient(context, gr_b,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r1Bounds), CGRectGetMidY(r1Bounds)), r1Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r1Bounds), CGRectGetMidY(r1Bounds)), r1Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r3 Drawing
    UIBezierPath* r3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.63462 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.02857 + 0.5), floor(CGRectGetWidth(frame) * 0.88462 + 0.5) - floor(CGRectGetWidth(frame) * 0.63462 + 0.5), floor(CGRectGetHeight(frame) * 0.25714 + 0.5) - floor(CGRectGetHeight(frame) * 0.02857 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r3Path addClip];
    UIBezierPath* r3RotatedPath = [r3Path copy];
    CGAffineTransform r3Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r3RotatedPath applyTransform: r3Transform];
    CGRect r3Bounds = CGPathGetPathBoundingBox(r3RotatedPath.CGPath);
    r3Transform = CGAffineTransformInvert(r3Transform);
    
    CGContextDrawLinearGradient(context, gr_b_l,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r3Bounds), CGRectGetMidY(r3Bounds)), r3Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r3Bounds), CGRectGetMidY(r3Bounds)), r3Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r4 Drawing
    UIBezierPath* r4Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.63462 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.33333 + 0.5), floor(CGRectGetWidth(frame) * 0.88462 + 0.5) - floor(CGRectGetWidth(frame) * 0.63462 + 0.5), floor(CGRectGetHeight(frame) * 0.58095 + 0.5) - floor(CGRectGetHeight(frame) * 0.33333 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r4Path addClip];
    UIBezierPath* r4RotatedPath = [r4Path copy];
    CGAffineTransform r4Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r4RotatedPath applyTransform: r4Transform];
    CGRect r4Bounds = CGPathGetPathBoundingBox(r4RotatedPath.CGPath);
    r4Transform = CGAffineTransformInvert(r4Transform);
    
    CGContextDrawLinearGradient(context, gr_b_l,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r4Bounds), CGRectGetMidY(r4Bounds)), r4Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r4Bounds), CGRectGetMidY(r4Bounds)), r4Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r8 Drawing
    UIBezierPath* r8Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00962 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.33333 + 0.5), floor(CGRectGetWidth(frame) * 0.25000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00962 + 0.5), floor(CGRectGetHeight(frame) * 0.58095 + 0.5) - floor(CGRectGetHeight(frame) * 0.33333 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r8Path addClip];
    UIBezierPath* r8RotatedPath = [r8Path copy];
    CGAffineTransform r8Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r8RotatedPath applyTransform: r8Transform];
    CGRect r8Bounds = CGPathGetPathBoundingBox(r8RotatedPath.CGPath);
    r8Transform = CGAffineTransformInvert(r8Transform);
    
    CGContextDrawLinearGradient(context, gr_b,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r8Bounds), CGRectGetMidY(r8Bounds)), r8Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r8Bounds), CGRectGetMidY(r8Bounds)), r8Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r2 Drawing
    UIBezierPath* r2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.31731 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.02857 + 0.5), floor(CGRectGetWidth(frame) * 0.55769 + 0.5) - floor(CGRectGetWidth(frame) * 0.31731 + 0.5), floor(CGRectGetHeight(frame) * 0.25714 + 0.5) - floor(CGRectGetHeight(frame) * 0.02857 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r2Path addClip];
    UIBezierPath* r2RotatedPath = [r2Path copy];
    CGAffineTransform r2Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r2RotatedPath applyTransform: r2Transform];
    CGRect r2Bounds = CGPathGetPathBoundingBox(r2RotatedPath.CGPath);
    r2Transform = CGAffineTransformInvert(r2Transform);
    
    CGContextDrawLinearGradient(context, gr_b_l,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r2Bounds), CGRectGetMidY(r2Bounds)), r2Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r2Bounds), CGRectGetMidY(r2Bounds)), r2Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r7 Drawing
    UIBezierPath* r7Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00962 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64762 + 0.5), floor(CGRectGetWidth(frame) * 0.25000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00962 + 0.5), floor(CGRectGetHeight(frame) * 0.89524 + 0.5) - floor(CGRectGetHeight(frame) * 0.64762 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r7Path addClip];
    UIBezierPath* r7RotatedPath = [r7Path copy];
    CGAffineTransform r7Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r7RotatedPath applyTransform: r7Transform];
    CGRect r7Bounds = CGPathGetPathBoundingBox(r7RotatedPath.CGPath);
    r7Transform = CGAffineTransformInvert(r7Transform);
    
    CGContextDrawLinearGradient(context, gr_b,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r7Bounds), CGRectGetMidY(r7Bounds)), r7Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r7Bounds), CGRectGetMidY(r7Bounds)), r7Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r6 Drawing
    UIBezierPath* r6Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.31731 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64762 + 0.5), floor(CGRectGetWidth(frame) * 0.55769 + 0.5) - floor(CGRectGetWidth(frame) * 0.31731 + 0.5), floor(CGRectGetHeight(frame) * 0.89524 + 0.5) - floor(CGRectGetHeight(frame) * 0.64762 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r6Path addClip];
    UIBezierPath* r6RotatedPath = [r6Path copy];
    CGAffineTransform r6Transform = CGAffineTransformMakeRotation(120*(-M_PI/180));
    [r6RotatedPath applyTransform: r6Transform];
    CGRect r6Bounds = CGPathGetPathBoundingBox(r6RotatedPath.CGPath);
    r6Transform = CGAffineTransformInvert(r6Transform);
    
    CGContextDrawLinearGradient(context, gr_b,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r6Bounds), CGRectGetMidY(r6Bounds)), r6Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r6Bounds), CGRectGetMidY(r6Bounds)), r6Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// r5 Drawing
    UIBezierPath* r5Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.64423 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64762 + 0.5), floor(CGRectGetWidth(frame) * 0.99038 + 0.5) - floor(CGRectGetWidth(frame) * 0.64423 + 0.5), floor(CGRectGetHeight(frame) * 0.99048 + 0.5) - floor(CGRectGetHeight(frame) * 0.64762 + 0.5)) cornerRadius: cornerRadius];
    CGContextSaveGState(context);
    [r5Path addClip];
    UIBezierPath* r5RotatedPath = [r5Path copy];
    CGAffineTransform r5Transform = CGAffineTransformMakeRotation(110*(-M_PI/180));
    [r5RotatedPath applyTransform: r5Transform];
    CGRect r5Bounds = CGPathGetPathBoundingBox(r5RotatedPath.CGPath);
    r5Transform = CGAffineTransformInvert(r5Transform);
    
    CGContextDrawLinearGradient(context, gr_g,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(r5Bounds), CGRectGetMidY(r5Bounds)), r5Transform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(r5Bounds), CGRectGetMidY(r5Bounds)), r5Transform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gr_b_l);
    CGGradientRelease(gr_g);
    CGGradientRelease(gr_b);
    CGColorSpaceRelease(colorSpace);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawQBLogoWithFrame:rect];
}


@end
