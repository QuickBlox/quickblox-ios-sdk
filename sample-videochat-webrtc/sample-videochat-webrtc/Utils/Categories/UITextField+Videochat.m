//
//  UITextField+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/24/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UITextField+Videochat.h"

@implementation UITextField (Videochat)

- (void)setPadding:(CGFloat)padding isLeft:(Boolean)isLeft {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, padding
    , self.frame.size.height)];
    if (isLeft) {
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    } else {
        self.rightView = paddingView;
        self.rightViewMode = UITextFieldViewModeAlways;
    }
}

- (void)addShadow:(UIColor *) color cornerRadius: (CGFloat)cornerRadius {
    self.backgroundColor = UIColor.whiteColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 6);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 6;
    self.layer.cornerRadius = cornerRadius;
}

@end
