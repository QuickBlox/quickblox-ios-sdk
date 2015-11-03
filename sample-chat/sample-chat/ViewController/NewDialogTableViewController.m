//
//  NewDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/29/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "NewDialogTableViewController.h"
#import "ServicesManager.h"
#import "UsersDataSource.h"
#import "ChatViewController.h"
#import "UIAlertDialog.h"

@interface NewDialogTableViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;

@end

@implementation NewDialogTableViewController

- (void)viewDidLoad
{
    self.dataSource = [[UsersDataSource alloc] initWithUsers:[[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers]];
    [self.dataSource setExcludeUsersIDs:@[@([QBSession currentSession].currentUser.ID)]];
    self.tableView.dataSource = self.dataSource;

	[super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self checkJoinChatButtonState];
	[self.tableView reloadData];
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
		UIAlertDialog *dialog = [[UIAlertDialog alloc] initWithStyle:UIAlertDialogStyleAlert title:@"Enter chat name:" andMessage:@""];
		
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
        // Creating private chat dialog.
		[ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:selectedUsers.firstObject completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if( !response.success  && createdDialog == nil ) {
				completion(nil);
			}
			else {
				completion(createdDialog);
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
		
		[SVProgressHUD showWithStatus:@"Creating dialog..." maskType:SVProgressHUDMaskTypeClear];
		
        // Creating group chat dialog.
		[ServicesManager.instance.chatService createGroupChatDialogWithName:name photo:nil occupants:selectedUsers completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if (response.success) {
                // Notifying users about created dialog.
				[ServicesManager.instance.chatService notifyUsersWithIDs:createdDialog.occupantIDs aboutAddingToDialog:createdDialog];
				completion(createdDialog);
			} else {
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