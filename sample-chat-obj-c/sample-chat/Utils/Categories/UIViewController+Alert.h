//
//  UIViewController+Alert.h
//  sample-chat
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)
- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
                   handler:(void (^ __nullable)(UIAlertAction *action))handler;
- (void)showNoInternetAlertWithHandler:(void (^ __nullable)(UIAlertAction *action))handler;
- (void)showAnimatedAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message;
- (void)showUnAuthorizeAlert:(NSString * _Nullable)message
                logoutAction:(void (^ __nullable)(UIAlertAction *action))logoutAction
              tryAgainAction:(void (^ __nullable)(UIAlertAction *action))tryAgainAction;
- (void)hideAlertView;
@end

NS_ASSUME_NONNULL_END
