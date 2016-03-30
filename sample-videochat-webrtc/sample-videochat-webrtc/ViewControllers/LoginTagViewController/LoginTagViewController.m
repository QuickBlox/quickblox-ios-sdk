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
#import "LoginManager.h"

@interface LoginTagViewController () <UITextFieldDelegate>
@property (nonatomic, strong) QBUUser *user;
@end

@implementation LoginTagViewController

NSString *const kOutgoingCallViewControllerWithTagIdentifier = @"OutgoingCallViewControllerWithTagID";

- (void)viewDidLoad {
	[super viewDidLoad];
	// setup table view auto sizing
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 80;
	
	[self.userName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[self.tag addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	QBUUser *cachedUser = [[SampleCore usersDataSource] currentUserWithDefaultPassword];
	
	if (cachedUser) {
		
		self.userName.text = cachedUser.fullName;
		self.tag.text = [cachedUser.tags firstObject];
		
		[self loginWithCachedUser:cachedUser];
	}
}

- (void)allowInput:(BOOL)enabled {
	self.tag.enabled = enabled;
	self.userName.enabled = enabled;
	self.login.enabled = enabled;
}

- (void)loginWithCachedUser:(QBUUser *)cachedUser {
	self.user = cachedUser;
	
	// MARK: Step 0
	[self loginWithCurrentUser];
}

- (IBAction)login:(UIButton *)sender {
	
	[self allowInput:NO];
	
	self.tag.text = [self.tag.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.userName.text = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	self.user = [QBUUser user];
	self.user.login = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	self.user.password = [[SampleCore usersDataSource] defaultPassword];
	self.user.fullName = self.userName.text;
	
	// MARK: Step 0
	[self loginWithCurrentUser];
}

- (void)loginWithCurrentUser {
	__weak __typeof(self)weakSelf = self;
	
	void (^errorBlock)(QBResponse *) = ^(QBResponse *response){
		if (response.error) {
			NSLog(@"Error %@", response.error);
		}
		[SVProgressHUD dismiss];
		[weakSelf allowInput:YES];
	};
	
	
	[SVProgressHUD setBackgroundColor:[UIColor grayColor]];
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in REST", nil)];
	
	[LoginManager loginOrSignupUser:self.user successBlock:^(QBResponse *response, QBUUser * _Nullable user) {
		__typeof(self)strongSelf = weakSelf;
		
		[strongSelf updateCurrentUserFullNameAndTagsWithSuccessBlock:^{
			
			// MARK: Step 5 - download users with tag
			// Note: There is always at least one user with given tag – current user
			[SampleCoreManager allUsersWithTags:@[strongSelf.tag.text] perPageLimit:50 successBlock:^(NSArray *usersObjects) {
				
				[[SampleCore usersDataSource] loadUsersWithArray:usersObjects tags:[@[strongSelf.tag.text] mutableCopy]];
				
				[strongSelf connectToChatWithErrorBlock:errorBlock];
				
			} errorBlock:errorBlock];
		} errorBlock:errorBlock];
	} errorBlock:errorBlock];
	
	
}

- (void)connectToChatWithErrorBlock:(void(^)(QBResponse *response))errorBlock {
	__weak __typeof(self)weakSelf = self;
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in Chat", nil)];
	
	// MARK: Step 5 - connect to chat
	[[SampleCoreManager instance] connectToChatWithUser:self.user successBlock:^{
		__typeof(self)strongSelf = weakSelf;
		
		[SampleCore usersDataSource].currentUser = strongSelf.user;
		
		[[SampleCore pushMessagesManager] registerForRemoteNotifications];
		// MARK: Step 6
		[strongSelf showUsersViewController];
		[SVProgressHUD dismiss];
		
	} errorBlock:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login chat error!", nil)];
		if (errorBlock) {
			errorBlock(nil);
		}
	} chatDisconnectedBlock:nil chatReconnectedBlock:nil];
	
}

- (void)showUsersViewController {
	[self allowInput:YES];
	
	UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	OutgoingCallViewController *outgoingVC = [st instantiateViewControllerWithIdentifier:kOutgoingCallViewControllerWithTagIdentifier];
	
	if ([self respondsToSelector:@selector(showViewController:sender:)]) {
		[self showViewController:outgoingVC sender:nil];
	} else {
		[self.navigationController pushViewController:outgoingVC animated:YES];
	}
}

- (void)updateCurrentUserFullNameAndTagsWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBResponse * _Nonnull response))errorBlock {
	QBUUser *currentUser = [[QBSession currentSession] currentUser];
	
	NSParameterAssert(currentUser);
	
	if ([currentUser.fullName isEqualToString:self.userName.text] &&
		[[currentUser tags] isEqualToArray:[@[self.tag.text] mutableCopy]]) {
		// when user information has not changed
		currentUser.password = self.user.password;
		
		self.user = currentUser;
		
		if (successBlock) {
			successBlock();
		}
		
		return;
	}
	
	QBUpdateUserParameters *updateParameters = [[QBUpdateUserParameters alloc] init];
	updateParameters.login = self.user.login;
	updateParameters.fullName = self.userName.text;
	updateParameters.tags = [@[self.tag.text] mutableCopy];
	
	__weak __typeof(self)weakSelf = self;
	
	[QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
		__typeof(self)strongSelf = weakSelf;
		
		strongSelf.user.fullName = user.fullName;
		strongSelf.user.tags = user.tags;
		strongSelf.user.ID = user.ID;
		
		if (successBlock) {
			successBlock();
		}
	} errorBlock:errorBlock];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewAutomaticDimension;
}

#pragma mark - UITextField

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
	
	NSString *userName = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSString *tag = [self.tag.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	self.login.enabled = userName.length >= minCharactersCount && tag.length >= minCharactersCount;
}

@end
