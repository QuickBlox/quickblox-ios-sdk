//
//  UILabel+Chat.m
//  sample-chat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UILabel+Chat.h"

@implementation UILabel (Chat)
   
- (void)setRoundedLabelWithCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
}

@end
