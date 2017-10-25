//
//  UIImage+QM.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "UIImage+QM.h"

@implementation UIImage (QM)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor {
    
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)resizableImageWithColor:(UIColor *)color
                        cornerRadius:(CGFloat)cornerRadius {
    
    CGFloat scale = UIScreen.mainScreen.scale;
    CGFloat size = 1.0 + 2 * cornerRadius;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, cornerRadius + 1.0, 0.0);
    CGPathAddArcToPoint(path, NULL, size, 0.0, size, cornerRadius, cornerRadius);
    CGPathAddLineToPoint(path, NULL, size, cornerRadius + 1.0);
    CGPathAddArcToPoint(path, NULL, size, size, cornerRadius + 1.0, size, cornerRadius);
    CGPathAddLineToPoint(path, NULL, cornerRadius, size);
    CGPathAddArcToPoint(path, NULL, 0.0, size, 0.0, cornerRadius + 1.0, cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0.0, cornerRadius);
    CGPathAddArcToPoint(path, NULL, 0.0, 0.0, cornerRadius, 0.0, cornerRadius);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
                                 resizingMode:UIImageResizingModeStretch];
}

@end
