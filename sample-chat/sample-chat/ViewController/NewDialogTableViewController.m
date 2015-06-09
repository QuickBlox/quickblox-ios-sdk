//
//  NewDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/29/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "NewDialogTableViewController.h"
#import "QBServicesManager.h"
#import "UsersDataSource.h"

@implementation NewDialogTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[(UsersDataSource *)self.tableView.dataSource setExcludeUsersIDs:@[@([QBSession currentSession].currentUser.ID)]];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self checkJoinChatButtonState];
}

- (void)checkJoinChatButtonState {
	self.navigationItem.rightBarButtonItem.enabled = self.tableView.indexPathsForSelectedRows.count != 0;
}

- (IBAction)joinChatButtonPressed:(UIButton *)sender {
	sender.enabled = NO;
	__weak __typeof(self) weakSelf = self;
	
	if( self.tableView.indexPathsForSelectedRows.count == 1 ){
		[self createChatWithName:nil completion:^{
			sender.enabled = YES;
		}];
	}
	else {
		UIAlertDialog *dialog = [[UIAlertDialog alloc] initWithStyle:UIAlertDialogStyleAlert title:@"Join chat" andMessage:@""];
		
		__weak UIAlertDialog *weakDialog = dialog;
		[dialog addButtonWithTitle:@"create" andHandler:^(NSInteger buttonIndex) {
			if( buttonIndex == 0 ) { // first button
				[weakSelf createChatWithName:[weakDialog textFieldText] completion:^{
					NSLog(@"cmmm");
				}];
			}
		}];
		dialog.showTextField = YES;
		dialog.textFieldPlaceholderText = @"Enter chat name";
		[dialog showInViewController:self];
	}
}

- (void)createChatWithName:(NSString *)name completion:(void(^)())completion {
	NSIndexSet *indexesForSelectedRows = [self.tableView.indexPathsForSelectedRows indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return YES;
	}];
	
	NSArray *selectedUsers = [QBServicesManager.instance.usersService.usersWithoutCurrentUser objectsAtIndexes:indexesForSelectedRows];
	
	if( selectedUsers.count == 1 ) {
		[QBServicesManager.instance.chatService createPrivateChatDialogWithOpponent:selectedUsers.firstObject completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			NSLog(@"%@", createdDialog);
			//TODO: perfom segue to chat
		}];
	}
	else if( selectedUsers.count > 1 ) {
		if( name == nil || [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
			name = [NSString stringWithFormat:@"%@_", [QBSession currentSession].currentUser.login];
			for( QBUUser *user in selectedUsers ) {
				name = [NSString stringWithFormat:@"%@%@,", name, user.login];
			}
			name = [name substringToIndex:name.length - 1]; // remove last , (comma)
		}

		[QBServicesManager.instance.chatService createGroupChatDialogWithName:name photo:nil occupants:selectedUsers completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			
//			[QBServicesManager.instance.chatService notifyAboutCreatedDialog:createdDialog excludedOccupantIDs:nil occupantsCustomParameters:nil completion:^(NSError *error) {
//				if( error == nil ) {
//					[SVProgressHUD showSuccessWithStatus:@"CreatedDialog notification successfully sent!"];
//				}
//			}];

			//TODO: perfom segue to chat
			NSLog(@"%@", createdDialog);
		}];
	}
	else {
		assert("no users given");
	}
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self checkJoinChatButtonState];
}


@end