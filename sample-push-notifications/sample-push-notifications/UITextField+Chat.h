//
//  UITextField+Chat.h
//  sample-push-notifications
//
//  Created by Injoit on 18.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Chat)

- (void)setPadding:(CGFloat)padding isLeft:(Boolean)isLeft;

- (void)addShadow:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
