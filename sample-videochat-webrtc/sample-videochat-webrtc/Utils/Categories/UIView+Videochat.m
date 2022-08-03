//
//  UIView+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIView+Videochat.h"

@implementation UIView (Videochat)

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)pinAllEdgesOfSubview:(UIView *)subview {
    
    [self pinSubview:subview toEdge:NSLayoutAttributeBottom];
    [self pinSubview:subview toEdge:NSLayoutAttributeTop];
    [self pinSubview:subview toEdge:NSLayoutAttributeLeading];
    [self pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

- (void)setRoundBorderEdgeColorView:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth color:(nullable UIColor *)color borderColor:(UIColor *)borderColor {
    if (color) {
        self.backgroundColor = color;
    }
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

- (void)roundTopCornersWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
}

- (void)roundCornersWithRadius:(CGFloat)radius isIncoming:(Boolean)isIncoming {
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    if (isIncoming) {
        self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        self.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
}

- (void)setRoundViewWithCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

- (void)addShadow:(UIColor *)color {
    self.backgroundColor = UIColor.whiteColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 12);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 11;
}

@end
