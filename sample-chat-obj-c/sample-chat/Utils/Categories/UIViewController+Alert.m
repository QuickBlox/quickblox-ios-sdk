//
//  UIViewController+Alert.m
//  samplechat
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
@end
