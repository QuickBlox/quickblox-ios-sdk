//
//  UIImage+Tint.h
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage*) imageWithImageTintColor:(UIColor*) color;
+ (UIImage *)convertImageToGrayScale:(UIImage *)image;

@end
