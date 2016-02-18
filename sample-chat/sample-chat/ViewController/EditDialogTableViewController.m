//
//  EditDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "EditDialogTableViewController.h"
#import "UsersDataSource.h"
#import "ServicesManager.h"
#import "UserTableViewCell.h"
#import "ChatViewController.h"
#import "DialogsViewController.h"

@interface EditDialogTableViewController() <QMChatServiceDelegate, QMChatConnectionDelegate>
@property (nonatomic, strong) UsersDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnSave;
@end

@implementation EditDialogTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
	NSParameterAssert(self.dialog);
}

- (void)reloadDataSource {
	self.dataSource = [[UsersDataSource alloc] init];
	[self.dataSource setExcludeUsersIDs:self.dialog.occupantIDs];
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadDataSource];
	[ServicesManager.instance.chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[ServicesManager.instance.chatService removeDelegate:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updateSaveButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updateSaveButtonState];
}

- (IBAction)saveButtonTapped:(id)sender {
	NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
	assert(indexPathArray.count != 0);
	
	NSMutableArray *users = [NSMutableArray arrayWithCapacity:indexPathArray.count];
	NSMutableArray *usersIDs = [NSMutableArray arrayWithCapacity:indexPathArray.count];
	
	for (NSIndexPath *indexPath in indexPathArray) {
		UserTableViewCell *selectedCell = (UserTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
		[users addObject:selectedCell.user];
		[usersIDs addObject:@(selectedCell.user.ID)];
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
	
	__weak __typeof(self)weakSelf = self;
	
	if (self.dialog.type == QBChatDialogTypePrivate) {
        // Retrieving users with identifiers.
        [[[ServicesManager instance].usersService getUsersWithIDs:self.dialog.occupantIDs] continueWithBlock:^id(BFTask *task) {
            //
            __typeof(self) strongSelf = weakSelf;
            [users addObjectsFromArray:task.result];
            
            [strongSelf createGroupDialogWithUsers:users];
            
            return nil;
        }];
	} else {
		[self updateGroupDialogWithUsersIDs:usersIDs];
	}
}

- (void)createGroupDialogWithUsers:(NSArray *)users {
	__weak __typeof(self)weakSelf = self;
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING", nil) maskType:SVProgressHUDMaskTypeClear];
	
    // Creating group chat dialog.
	[ServicesManager.instance.chatService createGroupChatDialogWithName:[self dialogNameFromUsers:users] photo:nil occupants:users completion:^(QBResponse *response, QBChatDialog *createdDialog) {
		
		if( response.success ) {
			[SVProgressHUD dismiss];
            [[ServicesManager instance].chatService sendSystemMessageAboutAddingToDialog:createdDialog toUsersIDs:createdDialog.occupantIDs completion:^(NSError *error) {
                //
            }];
			[weakSelf performSegueWithIdentifier:kGoToChatSegueIdentifier sender:createdDialog];
		}
		else {
			[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
			NSLog(@"can not create dialog: %@", response.error.error);
		}
	}];
}

- (void)updateGroupDialogWithUsersIDs:(NSArray *)usersIDs {
	__weak __typeof(self)weakSelf = self;
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING", nil) maskType:SVProgressHUDMaskTypeClear];
	
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService getUsersWithIDs:usersIDs] continueWithBlock:^id(BFTask *task) {
        //
        // Updating dialog with occupants.
        [ServicesManager.instance.chatService joinOccupantsWithIDs:usersIDs toChatDialog:self.dialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
            if( response.success ) {
                // Notifying users about newly created dialog.
                [[ServicesManager instance].chatService sendSystemMessageAboutAddingToDialog:updatedDialog toUsersIDs:usersIDs completion:^(NSError *error) {
                    //
                    NSString *notificationText = [weakSelf updatedMessageWithUsers:task.result];
                    // Notify occupants that dialog was updated.
                    [[ServicesManager instance].chatService sendMessageAboutUpdateDialog:updatedDialog withNotificationText:notificationText customParameters:nil completion:^(NSError *error) {
                        //
                    }];
                    
                    updatedDialog.lastMessageText = notificationText;
                    [weakSelf performSegueWithIdentifier:kGoToChatSegueIdentifier sender:updatedDialog];
                    [SVProgressHUD dismiss];
                }];
            }
            else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR", nil)];
            }
        }];
        
        return nil;
    }];
}

- (NSString *)dialogNameFromUsers:(NSArray *)users {
	NSString *name = [NSString stringWithFormat:@"%@_", [QBSession currentSession].currentUser.login];
	for (QBUUser *user in users) {
		name = [NSString stringWithFormat:@"%@%@,", name, user.login];
	}
	name = [name substringToIndex:name.length - 1]; // remove last , (comma)
	return name;
}

- (NSString *)updatedMessageWithUsers:(NSArray *)users {
	NSString *message = [NSString stringWithFormat:@"%@ %@ ", [ServicesManager instance].currentUser.login, NSLocalizedString(@"SA_STR_ADD", nil)];
	for (QBUUser *user in users) {
		message = [NSString stringWithFormat:@"%@%@,", message, user.login];
	}
	message = [message substringToIndex:message.length - 1]; // remove last , (comma)
	return message;
}

- (void)updateSaveButtonState {
	self.btnSave.enabled = [[self.tableView indexPathsForSelectedRows] count] != 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if( [segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
		ChatViewController *vc = (ChatViewController *) segue.destinationViewController;
		vc.dialog = sender;
		vc.shouldUpdateNavigationStack = YES;
	}
}

#pragma mark QMChatServiceDelegate delegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
	if( [chatDialog.ID isEqualToString:self.dialog.ID] ) {
		self.dialog = chatDialog;
		[self reloadDataSource];
	}
}

@end
