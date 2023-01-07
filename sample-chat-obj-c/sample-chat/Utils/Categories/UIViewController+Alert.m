//
//  UIViewController+Alert.m
//  sample-chat
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIViewController+Alert.h"

NSString *const STILL_CONNECTION = @"Still in connecting state, please wait";
NSString *const NO_INTERNET_CONNECTION = @"No Internet Connection";
NSString *const CHECK_INTERNET_MESSAGE = @"Make sure your device is connected to the internet";

@implementation UIViewController (Alert)
- (void)showNoInternetAlertWithHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:STILL_CONNECTION
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel handler:handler];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:NO completion:nil];
    });
}

- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
                   handler:(void (^ __nullable)(UIAlertAction *action))handler {
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel handler:handler];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:NO completion:nil];
    });
}

- (void)showUnAuthorizeAlert:(NSString * _Nullable)message
                logoutAction:(void (^ __nullable)(UIAlertAction *action))logoutAction
                tryAgainAction:(void (^ __nullable)(UIAlertAction *action))tryAgainAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Logout"
                                                            style:UIAlertActionStyleCancel handler:logoutAction]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Try Again"
                                                            style:UIAlertActionStyleDefault handler:tryAgainAction]];
        [self presentViewController:alertController animated:NO completion:nil];
    });
}

- (void)showAnimatedAlertWithTitle:(NSString * _Nullable)title
                           message:(NSString * _Nullable)message {
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:NO completion:^{
            [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                alertController.view.alpha = 0.0f;
            }
                             completion:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertController dismissViewControllerAnimated:NO completion:nil];
                });
            }];
        }];
    });
}

- (void)hideAlertView {
    if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
