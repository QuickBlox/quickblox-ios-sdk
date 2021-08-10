//
//  UIViewController+Alert.m
//  sample-conference-videochat
//
//  Created by Injoit on 12.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIViewController+Alert.h"
#import "Alert.h"
#import "ChatManager.h"

@implementation UIViewController (Alert)
- (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
        fromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        Alert *alertController = [Alert alertControllerWithTitle:title
                                                         message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            alertController.isPresented = NO;
            
            if (ChatManager.instance.onConnect) {
                return;
            }
            [ChatManager.instance establishConnection];
        }];
        [alertController addAction:cancelAction];
        [viewController presentViewController:alertController animated:NO completion:^{
            alertController.isPresented = YES;
        }]; 
    });
}
@end
