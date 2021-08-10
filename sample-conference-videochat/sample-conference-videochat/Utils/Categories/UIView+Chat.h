//
//  UIView+Chat.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Chat)
/**
 *  Pins the subview of the receiver to the edge of its frame, as specified by the given attribute, by adding a layout constraint.
 *
 *  @param subview   The subview to which the receiver will be pinned.
 *  @param attribute The layout constraint attribute specifying one of `NSLayoutAttributeBottom`, `NSLayoutAttributeTop`, `NSLayoutAttributeLeading`, `NSLayoutAttributeTrailing`.
 */
- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute;

/**
 *  Pins all edges of the specified subview to the receiver.
 *
 *  @param subview The subview to which the receiver will be pinned.
 */
- (void)pinAllEdgesOfSubview:(UIView *)subview;

- (void)setRoundBorderEdgeColorView:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth color:(nullable UIColor *)color borderColor:(UIColor *)borderColor;
- (void)roundTopCornersWithRadius:(CGFloat)radius;
- (void)setRoundViewWithCornerRadius:(CGFloat)cornerRadius;
- (void)roundCornersWithRadius:(CGFloat)radius isIncoming:(Boolean)isIncoming;

@end

NS_ASSUME_NONNULL_END
