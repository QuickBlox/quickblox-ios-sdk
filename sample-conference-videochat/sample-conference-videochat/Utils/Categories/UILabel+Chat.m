//
//  UILabel+Chat.m
//  sample-conference-videochat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UILabel+Chat.h"

@implementation UILabel (Chat)

- (void)setRoundedBorderEdgeLabelWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}
   
- (void)setRoundedLabelWithCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

@end
