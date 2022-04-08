//
//  UINavigationController+Appearance.m
//  sample-chat
//
//  Created by Injoit on 03.11.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

#import "UINavigationController+Appearance.h"
#import "UIColor+Chat.h"

@implementation UINavigationController (Appearance)
- (void)setupAppearanceWithColor:(UIColor * _Nullable)color titleColor:(UIColor *)titleColor {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = color == nil ? UIColor.appColor : color;
    appearance.shadowColor = color == nil ? UIColor.appColor : color;
    appearance.titleTextAttributes = [NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName];
    appearance.shadowImage = color == nil ? [UIImage imageNamed:@"navbar-shadow"] : UIImage.new;
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
}
@end
