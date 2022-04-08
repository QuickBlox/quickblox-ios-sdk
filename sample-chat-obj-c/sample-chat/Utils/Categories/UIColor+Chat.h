//
//  UIColor+Chat.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Chat)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)appColor;

@end


NS_ASSUME_NONNULL_END
