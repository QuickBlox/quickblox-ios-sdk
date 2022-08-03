//
//  UITextField+Videochat.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/24/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Videochat)

- (void)setPadding:(CGFloat)padding isLeft:(Boolean)isLeft;

- (void)addShadow:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
