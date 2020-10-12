//
//  UIViewController+Alert.h
//  samplechat
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)
- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
        fromViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
