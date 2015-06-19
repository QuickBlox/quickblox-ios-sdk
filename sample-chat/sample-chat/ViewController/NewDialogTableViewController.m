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
#import "ChatViewController.h"
#import "StorageManager.h"

@interface NewDialogTableViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;

@end

@implementation NewDialogTableViewController

- (void)viewDidLoad
{
    self.dataSource = [[UsersDataSource alloc] initWithUsers:[StorageManager instance].users];
    [self.dataSource setExcludeUsersIDs:@[@([QBSession currentSession].currentUser.ID)]];
    self.tableView.dataSource = self.dataSource;

	[super viewDidLoad];

	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self checkJoinChatButtonState];
}

- (void)checkJoinChatButtonState
{
	self.navigationItem.rightBarButtonItem.enabled = self.tableView.indexPathsForSelectedRows.count != 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* viewController = segue.destinationViewController;
        viewController.shouldUpdateNavigationStack = YES;
        viewController.dialog = sender;
    }
}

- (void)navigateToChatViewControllerWithDialog:(QBChatDialog *)dialog
{
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

- (IBAction)joinChatButtonPressed:(UIButton *)sender {
	__weak __typeof(self) weakSelf = self;
	
	if (self.tableView.indexPathsForSelectedRows.count == 1) {
		[self createChatWithName:nil completion:^(QBChatDialog *dialog) {
            __typeof(self) strongSelf = weakSelf;
			if( dialog != nil ) {
				[strongSelf navigateToChatViewControllerWithDialog:dialog];
			}
			else {
				[SVProgressHUD showErrorWithStatus:@"Can not create dialog"];
			}
		}];
	} else {
		UIAlertDialog *dialog = [[UIAlertDialog alloc] initWithStyle:UIAlertDialogStyleAlert title:@"Join chat" andMessage:@""];
		
		[dialog addButtonWithTitle:@"Create" andHandler:^(NSInteger buttonIndex, UIAlertDialog *dialog) {
            __typeof(self) strongSelf = weakSelf;
			sender.enabled = NO;
			[strongSelf createChatWithName:[dialog textFieldText] completion:^(QBChatDialog *dialog){
				sender.enabled = YES;
				if( dialog != nil ) {
					[strongSelf navigateToChatViewControllerWithDialog:dialog];
				}
				else {
					[SVProgressHUD showErrorWithStatus:@"Can not create dialog"];
				}
			}];
		}];
		dialog.showTextField = YES;
		dialog.textFieldPlaceholderText = @"Enter chat name";
		[dialog showInViewController:self];
	}
}

- (void)createChatWithName:(NSString *)name completion:(void(^)(QBChatDialog* dialog))completion
{
    NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [indexSet addIndex:obj.row];
    }];
	
	NSArray *selectedUsers = [self.dataSource.users objectsAtIndexes:indexSet];
	
	if (selectedUsers.count == 1) {
		[QBServicesManager.instance.chatService createPrivateChatDialogWithOpponent:selectedUsers.firstObject completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if( response.success ) {
				completion(createdDialog);
			}
			else {
				completion(nil);
			}
		}];
	} else if (selectedUsers.count > 1) {
		if (name == nil || [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
			name = [NSString stringWithFormat:@"%@_", [QBSession currentSession].currentUser.login];
			for (QBUUser *user in selectedUsers) {
				name = [NSString stringWithFormat:@"%@%@,", name, user.login];
			}
			name = [name substringToIndex:name.length - 1]; // remove last , (comma)
		}

		[QBServicesManager.instance.chatService createGroupChatDialogWithName:name photo:nil occupants:selectedUsers completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if( response.success ) {
				[QBServicesManager.instance.chatService notifyUsersWithIDs:createdDialog.occupantIDs aboutAddingToDialog:createdDialog];
				completion(createdDialog);
			}
			else {
				completion(nil);
			}
		}];
	} else {
		assert("no users given");
	}
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self checkJoinChatButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self checkJoinChatButtonState];
}

@end