//
//  UIImage+Cropper.m
//  QMChatViewController
//
//  Created by Igor Alefirenko on 29/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "UIImage+Cropper.h"
#include <math.h>

@implementation UIImage (Cropper)

- (UIImage *)imageByScaleAndCrop:(CGSize)targetSize {
    
    UIImage *newImage = nil;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (!CGSizeEqualToSize(self.size, targetSize)) {
        
        CGFloat widthFactor = targetWidth / self.size.width;
        CGFloat heightFactor = targetHeight / self.size.height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }
        else {
            
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = self.size.width * scaleFactor;
        scaledHeight = self.size.height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        } else if (widthFactor < heightFactor) {
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}

- (UIImage *)imageByCircularScaleAndCrop:(CGSize)targetSize {
    
    //bitmap context properties
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    CGColorSpaceRef colorSpace =
    CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(NULL,
                          targetSize.width * scaleFactor,
                          targetSize.height * scaleFactor,
                          8,
                          targetSize.width * scaleFactor * 4,
                          colorSpace,
                          kCGImageAlphaPremultipliedFirst);
    
    CGContextScaleCTM(context,
                      scaleFactor,
                      scaleFactor);
    
    CGContextBeginPath(context);
    
    CGContextAddArc(context,
                    targetSize.width / 2,
                    targetSize.height / 2,
                    targetSize.width / 2,
                    0,
                    2 * M_PI,
                    0);
    
    CGContextClosePath(context);
    
    CGFloat widthFactor = targetSize.width / self.size.width;
    CGFloat heightFactor = targetSize.height  / self.size.height;
    
    if (widthFactor > heightFactor) {
        scaleFactor = widthFactor;
    }
    else {
        
        scaleFactor = heightFactor;
    }
    
    float w = self.size.width * scaleFactor;
    float h = self.size.height * scaleFactor;
    
    CGContextClip(context);
    //draw image into bitmap context
    CGContextDrawImage(context,
                       CGRectMake(0,0, w, h),
                       self.CGImage);
    
    CGImageRef renderedImage =
    CGBitmapContextCreateImage(context);
    
    //tidy up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image =
    [UIImage imageWithCGImage:renderedImage
                        scale:scaleFactor
                  orientation:self.imageOrientation];
    
    return image;
}

@end
