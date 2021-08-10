//
//  UIImage+Cropper.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIImage+Cropper.h"

@implementation UIImage (Cropper)

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius
                        targetSize:(CGSize)targetSize {
    
    UIImage *scaledImage = [self imageByScaleAndCrop:targetSize];
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(scaledImage.size, NO, scaleFactor);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, scaledImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, scaledImage.size.width, scaledImage.size.height)
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, scaledImage.size.width, scaledImage.size.height), scaledImage.CGImage);

    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

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

        if (widthFactor > heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        } else {
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
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
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = self.size;
    }
    
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
    CGContextDrawImage(context,
                       CGRectMake(0,0, w, h),
                       self.CGImage);
    
    CGImageRef renderedImage =
    CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image =
    [UIImage imageWithCGImage:renderedImage
                        scale:0
                  orientation:self.imageOrientation];
    CGImageRelease(renderedImage);
    
    return image;
}

@end

