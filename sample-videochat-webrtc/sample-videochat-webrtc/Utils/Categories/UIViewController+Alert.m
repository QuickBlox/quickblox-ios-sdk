//
//  UIViewController+Alert.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)
- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
        fromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                                               style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        [viewController presentViewController:alertController animated:NO completion:nil];
        
    });
}

- (void)showAnimatedAlertWithTitle:(NSString * _Nullable)title
                           message:(NSString * _Nullable)message
                fromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [viewController presentViewController:alertController animated:NO completion:^{
            
            [UIView animateWithDuration:1.5f delay:2.0f options:UIViewAnimationOptionCurveEaseIn
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
@end
