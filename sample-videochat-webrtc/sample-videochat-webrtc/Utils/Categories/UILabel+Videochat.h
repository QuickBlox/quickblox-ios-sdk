//
//  UILabel+Videochat.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Videochat)

- (void)setRoundedBorderEdgeLabelWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (void)setRoundedLabelWithCornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
