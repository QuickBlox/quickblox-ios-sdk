//
//  UIColor+Chat.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIColor+Chat.h"

@implementation UIColor (Chat)
#pragma mark - Message bubble colors

+ (UIColor *)messageBubbleGreenColor {
    
    return [UIColor colorWithHue:130.0f / 360.0f saturation:0.68f brightness:0.84f alpha:1.0f];
}

+ (UIColor *)messageBubbleBlueColor {
    
    return [UIColor colorWithHue:210.0f / 360.0f saturation:0.94f brightness:1.0f alpha:1.0f];
}

+ (UIColor *)messageBubbleRedColor {
    
    return [UIColor colorWithHue:0.0f / 360.0f saturation:0.79f brightness:1.0f alpha:1.0f];
}

+ (UIColor *)messageBubbleLightGrayColor {
    
    return [UIColor colorWithHue:240.0f / 360.0f saturation:0.02f brightness:0.92f alpha:1.0f];
}

+ (UIColor *)colorWithIndex:(NSInteger)index {
    NSArray *colors = @[[UIColor colorWithRed:0.95f green:0.67f blue:0.13f alpha:1.0f],
                        [UIColor colorWithRed:0.31f green:0.87f blue:0.44f alpha:1.0f],
                        [UIColor colorWithRed:0.26f green:0.76f blue:0.97f alpha:1.0f],
                        [UIColor colorWithRed:0.86f green:0.25f blue:0.48f alpha:1.0f],
                        [UIColor colorWithRed:0.02f green:0.64f blue:0.60f alpha:1.0f],
                        [UIColor colorWithRed:0.53f green:0.33f blue:0.91f alpha:1.0f],
                        [UIColor colorWithRed:0.00f green:0.57f blue:1.00f alpha:1.0f],
                        [UIColor colorWithRed:0.84f green:0.87f blue:0.35f alpha:1.0f],
                        [UIColor colorWithRed:0.09f green:0.78f blue:0.86f alpha:1.0f],
                        [UIColor colorWithRed:1.00f green:0.40f blue:0.05f alpha:1.0f],
                        [UIColor colorWithRed:1.00f green:0.52f blue:0.99f alpha:1.0f],
                        [UIColor colorWithRed:1.00f green:0.01f blue:0.09f alpha:1.0f]];
    if (index >= 0) {
        return colors[index % 10];
    } else {
        return [UIColor blackColor];
    }
}

#pragma mark - Utilities

- (UIColor *)colorByDarkeningColorWithValue:(CGFloat)value {
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

@end

