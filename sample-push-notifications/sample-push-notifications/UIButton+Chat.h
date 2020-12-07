//
//  UIButton+Chat.h
//  sample-push-notifications
//
//  Created by Injoit on 18.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Chat)
- (void)addShadowToButton:(CGFloat)cornerRadius color:(nullable UIColor *)color;
- (void)removeShadowFromButton;
@end

NS_ASSUME_NONNULL_END
