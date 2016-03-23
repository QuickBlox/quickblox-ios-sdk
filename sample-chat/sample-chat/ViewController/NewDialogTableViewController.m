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

- (void)viewDidLoad {
    self.dataSource = [[UsersDataSource alloc] initWithUsers:[[ServicesManager instance] sortedUsers]];
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

- (void)checkJoinChatButtonState {
	self.navigationItem.rightBarButtonItem.enabled = self.tableView.indexPathsForSelectedRows.count != 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* viewController = segue.destinationViewController;
        viewController.dialog = sender;
    }
}

- (void)navigateToChatViewControllerWithDialog:(QBChatDialog *)dialog {
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
				[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
			}
		}];
	} else {
		UIAlertDialog *dialog = [[UIAlertDialog alloc] initWithStyle:UIAlertDialogStyleAlert title:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SA_STR_ENTER_CHAT_NAME", nil)] andMessage:@""];
		
		[dialog addButtonWithTitle:NSLocalizedString(@"SA_STR_CREATE", nil) andHandler:^(NSInteger buttonIndex, UIAlertDialog *dialog) {
            __typeof(self) strongSelf = weakSelf;
			sender.enabled = NO;
			[strongSelf createChatWithName:[dialog textFieldText] completion:^(QBChatDialog *dialog){
				sender.enabled = YES;
				if( dialog != nil ) {
					[strongSelf navigateToChatViewControllerWithDialog:dialog];
				}
				else {
					[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
				}
			}];
		}];
		dialog.showTextField = YES;
		dialog.textFieldPlaceholderText = NSLocalizedString(@"SA_STR_ENTER_CHAT_NAME", nil);
		[dialog showInViewController:self];
	}
}

/**
 *  Creates a chat with name
 *  If name is empty, then "login1_login2, login3, login4" string will be used as a chat name, where login1 is
 *  a dialog creator(owner)
 *
 *  @param name       chat name, can be nil
 *  @param completion completion block
 */
- (void)createChatWithName:(NSString *)name completion:(void(^)(QBChatDialog *dialog))completion {
    NSMutableIndexSet *selectedUsersIndexSet = [NSMutableIndexSet indexSet];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [selectedUsersIndexSet addIndex:obj.row];
    }];
	
	NSArray<QBUUser*> *selectedUsers = [self.dataSource.users objectsAtIndexes:selectedUsersIndexSet];
	
	if (selectedUsers.count == 1) {
        // Creating private chat dialog.
		[ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:selectedUsers.firstObject completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if (!response.success  && createdDialog == nil) {
				if (completion) {
					completion(nil);
				}
			}
			else {
				if (completion) {
					completion(createdDialog);
				}
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
		
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING", nil) maskType:SVProgressHUDMaskTypeClear];
		
        // Creating group chat dialog.
		[ServicesManager.instance.chatService createGroupChatDialogWithName:name photo:nil occupants:selectedUsers completion:^(QBResponse *response, QBChatDialog *createdDialog) {
			if (response.success) {
                // Notifying users about created dialog.
                [[ServicesManager instance].chatService sendSystemMessageAboutAddingToDialog:createdDialog toUsersIDs:createdDialog.occupantIDs completion:^(NSError *error) {
                    //
					if (completion) {
						completion(createdDialog);
					}
                }];
			} else {
				if (completion) {
					completion(nil);
				}
			}
		}];
	} else {
		assert("no given users");
	}
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self checkJoinChatButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self checkJoinChatButtonState];
}

@end
