//
//  UIButton+Chat.h
//  samplechat
//
//  Created by Injoit on 23.07.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Chat)
- (void)addShadowToButton:(CGFloat)cornerRadius color:(nullable UIColor *)color;
- (void)removeShadowFromButton;
@end

NS_ASSUME_NONNULL_END
