// Copyright (c) 2014 George N7 Kasapidi. All rights reserved.

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIAlertDialogStyle) {
	UIAlertDialogStyleAlert = 0,
	UIAlertDialogStyleActionSheet
};

@class UIAlertDialog;

typedef void(^UIAlertDialogHandler)(NSInteger buttonIndex, UIAlertDialog *dialog);


@interface UIAlertDialog : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

- (instancetype)initWithStyle:(UIAlertDialogStyle)style title:(NSString *)title andMessage:(NSString *)message;

- (void)addButtonWithTitle:(NSString *)title andHandler:(UIAlertDialogHandler)handler;

- (void)showInViewController:(UIViewController *)viewContoller;

/**
 *  Default value: NO
 */
@property (nonatomic, assign) BOOL showTextField;

/**
 *  Only if showTextField is YES
 */
@property (nonatomic, assign) NSString *textFieldText;

/**
 *  Only if showTextField is YES
 */
@property (nonatomic, assign) NSString *textFieldPlaceholderText;

@end