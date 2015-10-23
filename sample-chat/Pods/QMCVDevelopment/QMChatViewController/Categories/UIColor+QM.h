//
//  UIColor+q_municate.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (QM)

#pragma mark - Message bubble colors

/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app green bubble color.
 */
+ (UIColor *)messageBubbleGreenColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app blue bubble color.
 */
+ (UIColor *)messageBubbleBlueColor;

/**
 *  @return A color object containing HSB values similar to the iOS 7 red color.
 */
+ (UIColor *)messageBubbleRedColor;
/**
 *  @return A color object containing HSB values similar to the iOS 7 messages app light gray bubble color.
 */
+ (UIColor *)messageBubbleLightGrayColor;

#pragma mark - Utilities

/**
 *  Creates and returns a new color object whose brightness component is decreased by the given value, using the initial color values of the receiver.
 *
 *  @param value A floating point value describing the amount by which to decrease the brightness of the receiver.
 *
 *  @return A new color object whose brightness is decreased by the given values. The other color values remain the same as the receiver.
 */
- (UIColor *)colorByDarkeningColorWithValue:(CGFloat)value;

@end
