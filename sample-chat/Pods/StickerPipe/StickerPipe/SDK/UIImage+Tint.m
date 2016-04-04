//
//  UIImage+Tint.m
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage*)imageWithImageTintColor:(UIColor *)color {
    // Construct new image the same size as this one.
    if (color) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextClipToMask(context, rect, self.CGImage);
        [color setFill];
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    }
    return self;
    
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
    [filter setValue:beginImage forKey:@"inputImage"];
    CIImage *output = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

@end
