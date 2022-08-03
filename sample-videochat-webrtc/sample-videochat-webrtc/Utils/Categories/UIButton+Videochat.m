//
//  UIButton+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 23.07.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIButton+Videochat.h"
#import "UIColor+Videochat.h"

@implementation UIButton (Videochat)
- (void)addShadowToButton:(CGFloat)cornerRadius color:(nullable UIColor *)color {
    if (!color) {
        color = UIColor.blueBarColor;
    }
    self.backgroundColor = UIColor.whiteColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 11.0f;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = NO;
}

- (void)removeShadowFromButton {
    self.backgroundColor = UIColor.clearColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowColor = UIColor.clearColor.CGColor;
    self.layer.shadowOpacity = 0.0f;
    self.layer.shadowRadius = 0.0f;
    self.layer.cornerRadius = 0.0f;
    self.layer.masksToBounds = NO;
}
@end
