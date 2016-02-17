//
//  UIImage+Cropper.m
//  ChattAR
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
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGContextBeginPath (context);
    CGContextAddArc(context, targetSize.width / 2, targetSize.height / 2, targetSize.width / 2, 0, 2 * M_PI, 0);
    CGContextClosePath (context);
    CGContextClip(context);
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, targetSize.width / self.size.width, targetSize.height / self.size.height);
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:myRect];
    
    UIImage *circularImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return circularImage;
}

@end
