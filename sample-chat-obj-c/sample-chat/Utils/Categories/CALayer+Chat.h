//
//  CALayer+Chat.h
//  samplechat
//
//  Created by Injoit on 2/7/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (Chat)
- (void)applyShadowWithColor:(UIColor * _Nullable)color
                       alpha:(CGFloat)alpha
                        forX:(CGFloat)x
                        forY:(CGFloat)y
                        blur:(CGFloat)blur
                      spread:(CGFloat)spread
                        path:(UIBezierPath * _Nullable)path;
@end

NS_ASSUME_NONNULL_END
