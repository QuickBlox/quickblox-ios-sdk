//
//  CALayer+Chat.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/7/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CALayer+Chat.h"

@implementation CALayer (Chat)

- (void)applyShadowWithColor:(UIColor * _Nullable)color
                       alpha:(CGFloat)alpha
                        forX:(CGFloat)x
                        forY:(CGFloat)y
                        blur:(CGFloat)blur
                      spread:(CGFloat)spread
                        path:(UIBezierPath * _Nullable)path {
    
    if (color) {
        self.shadowColor = color.CGColor;
    } else {
        self.shadowColor = [UIColor colorWithRed:0.29f green:0.56f blue:0.99f alpha:1.0f].CGColor;
    }
    
    self.shadowOpacity = alpha;
    self.shadowRadius = blur/2;
    
    if (path) {
        if (spread == 0) {
            self.shadowOffset = CGSizeMake(x, y);
        } else {
            CGFloat scaleX = (path.bounds.size.width + (spread * 2)) / path.bounds.size.width;
            CGFloat scaleY = (path.bounds.size.height + (spread * 2)) / path.bounds.size.height;
            CGAffineTransform transform = CGAffineTransformMakeTranslation( x + -spread, y + -spread);
            transform = CGAffineTransformScale(transform, scaleX, scaleY);
            [path applyTransform:(transform)];
            self.shadowPath = path.CGPath;
        }
    } else {
        self.shadowOffset = CGSizeMake(x, y);
        if (spread == 0) {
            self.shadowPath = nil;
        } else {
            CGFloat dx = -spread;
            CGRect rect = CGRectInset(self.bounds, dx, dx);
            self.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
        }
    }
    self.shouldRasterize = YES;
    self.rasterizationScale = UIScreen.mainScreen.scale;
}

@end
