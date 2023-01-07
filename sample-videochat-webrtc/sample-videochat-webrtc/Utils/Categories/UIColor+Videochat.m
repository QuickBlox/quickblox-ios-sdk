//
//  UIColor+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIColor+Videochat.h"

@implementation UIColor (Videochat)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)blueBarColor {
    return [UIColor colorWithRed:57/255.0 green:120/255.0 blue:252/255.0 alpha:1.0];
}

+ (UIColor *)appColor {
    return [UIColor colorWithRed:57/255.0 green:120/255.0 blue:252/255.0 alpha:1.0];
}

@end

