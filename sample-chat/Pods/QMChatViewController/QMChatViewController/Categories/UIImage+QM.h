//
//  UIImage+QM.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QM)

/**
 *  Adds color mask to image
 *
 *  @param maskColor color for mask
 *
 *  @return masked image
 */
- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;

@end
