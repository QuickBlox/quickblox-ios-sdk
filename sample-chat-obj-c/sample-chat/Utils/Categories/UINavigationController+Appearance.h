//
//  UINavigationController+Appearance.h
//  sample-chat
//
//  Created by Injoit on 03.11.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (Appearance)
- (void)setupAppearanceWithColor:(UIColor * _Nullable)color titleColor:(UIColor *)titleColor;
@end

NS_ASSUME_NONNULL_END
