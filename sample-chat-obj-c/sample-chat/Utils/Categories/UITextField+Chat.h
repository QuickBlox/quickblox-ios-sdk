//
//  UITextField+Chat.h
//  samplechat
//
//  Created by Injoit on 1/24/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Chat)

- (void)setPadding:(CGFloat)padding isLeft:(Boolean)isLeft;

- (void)addShadowToTextFieldWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
