// Copyright (c) 2014 George N7 Kasapidi. All rights reserved.

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIAlertDialogStyle) {
    UIAlertDialogStyleAlert = 0,
    UIAlertDialogStyleActionSheet
};

typedef void(^UIAlertDialogHandler)(NSInteger buttonIndex);

@interface UIAlertDialog : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

- (instancetype)initWithStyle:(UIAlertDialogStyle)style title:(NSString *)title andMessage:(NSString *)message;

- (void)addButtonWithTitle:(NSString *)title andHandler:(UIAlertDialogHandler)handler;

- (void)showInViewController:(UIViewController *)viewContoller;

@end
