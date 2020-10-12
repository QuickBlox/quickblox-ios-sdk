//
//  UILabel+Chat.h
//  samplechat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Chat)

- (void)setRoundedBorderEdgeLabelWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (void)setRoundedLabelWithCornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
