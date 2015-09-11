// Copyright (c) 2014 George N7 Kasapidi. All rights reserved.

#import "UIAlertDialog.h"

#define CLOSE_TEXT @"Close"

#pragma mark - UIAlertViewDialog

@interface UIAlertViewDialog : UIAlertView

@property (strong, nonatomic) UIAlertDialog *alertDialog;

@end

@implementation UIAlertViewDialog

@end

#pragma mark - UIActionSheetDialog

@interface UIActionSheetDialog : UIActionSheet

@property (strong, nonatomic) UIAlertDialog *alertDialog;

@end

@implementation UIActionSheetDialog

@end

#pragma mark - UIAlertDialogItem

@interface UIAlertDialogItem : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) UIAlertDialogHandler handler;

@end

@implementation UIAlertDialogItem

@end

#pragma mark - UIAlertDialog

@interface UIAlertDialog ()

@property (nonatomic) UIAlertDialogStyle style;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) UIAlertViewDialog *alertView;
@property (strong, nonatomic) UIAlertController *alertController;
@end

@implementation UIAlertDialog

- (instancetype)initWithStyle:(UIAlertDialogStyle)style title:(NSString *)title andMessage:(NSString *)message {
	if (self = [super init]) {
		self.style = style;
		self.title = title;
		self.message = message;
		self.items = [NSMutableArray new];
	}
	
	return self;
}

- (void)addButtonWithTitle:(NSString *)title andHandler:(UIAlertDialogHandler)handler {
	UIAlertDialogItem *item = [UIAlertDialogItem new];
	
	item.title = title;
	item.handler = handler;
	
	[self.items addObject:item];
}

- (void)showInViewController:(UIViewController *)viewContoller {
	if ([[UIDevice currentDevice].systemVersion integerValue] > 7) {
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self showAlertControllerInViewController:viewContoller];
		}];
		
		return;
	}
	
	if (self.style == UIAlertDialogStyleActionSheet) {
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self showActionSheetInView:viewContoller.view];
		}];
	}
	else {
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self showAlert];
		}];
	}
}

- (void)showAlertControllerInViewController:(UIViewController *)viewController {
	self.alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:self.style == UIAlertDialogStyleActionSheet ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert];
	
	UIAlertAction *closeAction = [UIAlertAction actionWithTitle:CLOSE_TEXT style:UIAlertActionStyleCancel handler:nil];
	
	[self.alertController addAction:closeAction];
	
	NSInteger i = 0;
	
	for (UIAlertDialogItem *item in self.items) {
		UIAlertAction *alertAction = [UIAlertAction actionWithTitle:item.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			NSInteger buttonIndex = i;
			
			if (item.handler) {
				item.handler(buttonIndex, self);
			}
		}];
		
		[self.alertController addAction:alertAction];
		
		i++;
	}
	if( self.showTextField ){
		__weak __typeof(self)weakSelf = self;
		[self.alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			textField.placeholder = weakSelf.textFieldPlaceholderText;
		}];
	}
	
	[viewController presentViewController:self.alertController animated:YES completion:nil];
}

- (void)showAlert {
	self.alertView = [[UIAlertViewDialog alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[self.alertView addButtonWithTitle:CLOSE_TEXT];
	self.alertView.alertDialog = self;
	
	for (UIAlertDialogItem *item in self.items) {
		[self.alertView addButtonWithTitle:item.title];
	}
	
	if( self.showTextField ){
		self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		if( self.textFieldPlaceholderText != nil ) {
			[[self.alertView textFieldAtIndex:0] setPlaceholder:self.textFieldPlaceholderText];
		}
	}
	
	self.alertView.cancelButtonIndex = 0;
	
	[self.alertView show];
}

- (void)showActionSheetInView:(UIView *)view {
	UIActionSheetDialog *actionSheet = [[UIActionSheetDialog alloc] initWithTitle:self.title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	actionSheet.alertDialog = self;
	
	for (UIAlertDialogItem *item in self.items) {
		[actionSheet addButtonWithTitle:item.title];
	}
	
	[actionSheet addButtonWithTitle:CLOSE_TEXT];
	
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showInView:view.window];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertViewDialog *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		return;
	}
	buttonIndex = buttonIndex -1; // minus "cancel"
	
	UIAlertDialogItem *item = self.items[buttonIndex];
	
	if (item.handler) {
		item.handler(buttonIndex, self);
	}
}

- (void)alertView:(UIAlertViewDialog *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	alertView.alertDialog = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheetDialog *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.numberOfButtons - 1) {
		return;
	}
	
	UIAlertDialogItem *item = self.items[buttonIndex];
	
	if (item.handler) {
		item.handler(buttonIndex, self);
	}
}

- (void)actionSheet:(UIActionSheetDialog *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	actionSheet.alertDialog = nil;
}

- (NSString *)textFieldText {
	if ([[UIDevice currentDevice].systemVersion integerValue] > 7) {
		return [(UITextField *)self.alertController.textFields.firstObject text];
	}
	else {
		return [self.alertView textFieldAtIndex:0].text;
	}
}

@end