//
//  UIImage+Cropper.h
//  ChattAR
//
//  Created by Igor Alefirenko on 29/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cropper)

- (UIImage *)imageByScaleAndCrop:(CGSize)targetSize;
- (UIImage *)imageByCircularScaleAndCrop:(CGSize)targetSize;

@end
