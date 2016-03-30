//
//  LoginTagViewController.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/11/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "LoginTagViewController.h"
#import "OutgoingCallViewController.h"
#import "PushMessagesManager.h"
#import "SVProgressHUD.h"
#import "UsersDataSourceProtocol.h"
#import <AdSupport/ASIdentifierManager.h>

#import "SampleCoreManager.h"
#import "LoginHelper.h"

#import "LoginViewControllerManager.h"

@interface LoginTagViewController () <UITextFieldDelegate>

@property (nonatomic, strong) LoginViewControllerManager *manager;
@end

@implementation LoginTagViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// setup table view auto sizing
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 80;
	
	LoginViewControllerManager *manager = [[LoginViewControllerManager alloc] init];
	
	self.output = manager;
	manager.input = self;
	
	[self.userInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[self.tag addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[self.output loginViewControllerViewDidLoad:self];
}

- (IBAction)login:(UIButton *)sender {
	
	[self.output loginViewControllerDidTapLoginButton:self];
}

- (void)setInputEnabled:(BOOL)enabled {
	self.tag.enabled = enabled;
	self.userInput.enabled = enabled;
	self.login.enabled = enabled;
}

#pragma mark LoginViewControllerInput

- (void)enableInput {
	[self setInputEnabled:YES];
}

- (void)disableInput {
	[self setInputEnabled:NO];
}

- (void)showViewController:(UIViewController *)viewController {
	if ([self respondsToSelector:@selector(showViewController:sender:)]) {
		[self showViewController:viewController sender:nil];
	} else {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (NSArray *)tags {
	return [self.tag.text componentsSeparatedByString:@","];
}

- (NSString *)userName {
	return self.userInput.text;
}

- (void)setTags:(NSArray *)tags {
	self.tag.text = [tags componentsJoinedByString:@","];
}

- (void)setUserName:(NSString *)userName {
	self.userInput.text = userName;
}

#pragma mark - UITextFieldDelegate methods

/// Limit max length of tag text field to 15
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField != self.tag) {
		return YES; // username can be longer than 15 characters
	}
	
	// Prevent crashing undo bug – see http://stackoverflow.com/a/1773257/760518
	if(range.length + range.location > textField.text.length) {
		return NO;
	}
	NSUInteger newLength = [textField.text length] + [string length] - range.length;
	return newLength <= 15; // max Quickblox tag length
}

/// Enable login button when user enters 3+ characters
- (void)textFieldDidChange:(id)sender {
	NSUInteger minCharactersCount = 3;
	
	NSString *userName = [self.userInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSString *tag = [self.tag.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	self.login.enabled = userName.length >= minCharactersCount && tag.length >= minCharactersCount;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewAutomaticDimension;
}

@end
