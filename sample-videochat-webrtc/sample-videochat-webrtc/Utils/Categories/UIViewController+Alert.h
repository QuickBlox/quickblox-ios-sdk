//
//  UIViewController+Alert.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)
- (void)showNoInternetAlertWithHandler:(void (^ __nullable)(UIAlertAction *action))handler;
- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message;
- (void)showAnimatedAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message;
- (void)showUnAuthorizeAlert:(NSString * _Nullable)message
                logoutAction:(void (^ __nullable)(UIAlertAction *action))logoutAction
              tryAgainAction:(void (^ __nullable)(UIAlertAction *action))tryAgainAction;
- (void)hideAlertView;
@end

NS_ASSUME_NONNULL_END
