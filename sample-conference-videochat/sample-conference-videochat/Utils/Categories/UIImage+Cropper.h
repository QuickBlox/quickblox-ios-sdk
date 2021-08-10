//
//  UIImage+Cropper.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Cropper)

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius
                        targetSize:(CGSize)targetSize;
- (UIImage *)imageByScaleAndCrop:(CGSize)targetSize;
- (UIImage *)imageByCircularScaleAndCrop:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
