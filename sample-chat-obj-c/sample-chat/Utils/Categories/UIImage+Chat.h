//
//  UIImage+Chat.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Chat)
/**
 *  Adds color mask to image
 *
 *  @param maskColor color for mask
 *
 *  @return masked image
 */
- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;

/**
 *  Creates a resizable image with specified color and corner radius
 *
 *  @param color color for mask
 *
 *  @return masked image
 */
+ (UIImage *)resizableImageWithColor:(UIColor *)color
                        cornerRadius:(CGFloat)cornerRadius;

@property (nonatomic, strong, readonly) NSData *dataRepresentation;

@end

NS_ASSUME_NONNULL_END
