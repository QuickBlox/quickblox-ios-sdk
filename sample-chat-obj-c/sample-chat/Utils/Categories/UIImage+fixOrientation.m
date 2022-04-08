//
//  UIImage+fixOrientation.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIImage+fixOrientation.h"

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    CGAffineTransform transformOrientation = CGAffineTransformIdentity;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    if (self.imageOrientation == UIImageOrientationDown || self.imageOrientation == UIImageOrientationDownMirrored) {
        transformOrientation = CGAffineTransformTranslate(transformOrientation, width, height);
        transformOrientation = CGAffineTransformRotate(transformOrientation, M_PI);
    } else if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored) {
        transformOrientation = CGAffineTransformTranslate(transformOrientation, width, 0);
        transformOrientation = CGAffineTransformRotate(transformOrientation, M_PI_2);
    } else if (self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored) {
        transformOrientation = CGAffineTransformTranslate(transformOrientation, 0, height);
        transformOrientation = CGAffineTransformRotate(transformOrientation, -M_PI_2);
    }
    
    if (self.imageOrientation == UIImageOrientationUpMirrored || self.imageOrientation == UIImageOrientationDownMirrored) {
        transformOrientation = CGAffineTransformTranslate(transformOrientation, width, 0);
        transformOrientation = CGAffineTransformScale(transformOrientation, -1, 1);
    } else if (self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRightMirrored) {
        transformOrientation = CGAffineTransformTranslate(transformOrientation, height, 0);
        transformOrientation = CGAffineTransformScale(transformOrientation, -1, 1);
    }
    
    CGImageRef cgImage = self.CGImage;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(cgImage), 0, CGImageGetColorSpace(cgImage), CGImageGetBitmapInfo(cgImage));
    CGContextConcatCTM(context, transformOrientation);
    
    if (self.imageOrientation == UIImageOrientationLeft ||
        self.imageOrientation == UIImageOrientationLeftMirrored ||
        self.imageOrientation == UIImageOrientationRight ||
        self.imageOrientation == UIImageOrientationRightMirrored) {
        CGContextDrawImage(context, CGRectMake(0, 0, height, width), cgImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:newCGImage];
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    return image;
}

@end
