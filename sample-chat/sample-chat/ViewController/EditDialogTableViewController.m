//
//  EditDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "EditDialogTableViewController.h"
#import "UsersDataSource.h"
#import "QBServicesManager.h"
#import "UserTableViewCell.h"
#import "ChatViewController.h"
#import "DialogsViewController.h"

@interface EditDialogTableViewController()
@property (nonatomic, strong) UsersDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnSave;
@end

@implementation EditDialogTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSParameterAssert(self.dialog);

	self.dataSource = [[UsersDataSource alloc] init];
	[self.dataSource setExcludeUsersIDs:self.dialog.occupantIDs];
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];
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
	
	for( NSIndexPath *indexPath in indexPathArray ) {
		UserTableViewCell *selectedCell = (UserTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
		[users addObject:selectedCell.user];
		[usersIDs addObject:@(selectedCell.user.ID)];
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
	
	__weak __typeof(self)weakSelf = self;
	
	if( self.dialog.type == QBChatDialogTypePrivate ) {
		
		[QBServicesManager.instance.usersService retrieveUsersWithIDs:self.dialog.occupantIDs completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *occupants) {
			[users addObjectsFromArray:occupants];
			
			[weakSelf createGroupDialogWithUsers:users];
		}];
	}
	else {
		[self updateGroupDialogWithUsersIDs:usersIDs];
	}
}

- (void)createGroupDialogWithUsers:(NSArray *)users {
	__weak __typeof(self)weakSelf = self;
	
	[SVProgressHUD showWithStatus:@"Creating dialog..." maskType:SVProgressHUDMaskTypeClear];
	
	[QBServicesManager.instance.chatService createGroupChatDialogWithName:[self dialogNameFromUsers:users] photo:nil occupants:users completion:^(QBResponse *response, QBChatDialog *createdDialog) {
		
		if( response.success ) {
			[SVProgressHUD dismiss];
			[QBServicesManager.instance.chatService notifyUsersWithIDs:createdDialog.occupantIDs aboutAddingToDialog:createdDialog];
			[weakSelf performSegueWithIdentifier:kGoToChatSegueIdentifier sender:createdDialog];
		}
		else {
			[SVProgressHUD showErrorWithStatus:@"Can not create dialog"];
			NSLog(@"can not create dialog: %@", response.error.error);
		}
	}];
}

- (void)updateGroupDialogWithUsersIDs:(NSArray *)usersIDs {
	__weak __typeof(self)weakSelf = self;
	
	[SVProgressHUD showWithStatus:@"Updating dialog..." maskType:SVProgressHUDMaskTypeClear];
	
	[QBServicesManager.instance.usersService.contactListService retrieveUsersWithIDs:usersIDs forceDownload:NO completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
		
		[QBServicesManager.instance.chatService joinOccupantsWithIDs:usersIDs toChatDialog:self.dialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
			if( response.success ) {
				[QBServicesManager.instance.chatService notifyUsersWithIDs:usersIDs aboutAddingToDialog:weakSelf.dialog];
				
				NSString *notificationText = [weakSelf updatedMessageWithUsers:users];
				[QBServicesManager.instance.chatService notifyAboutUpdateDialog:updatedDialog occupantsCustomParameters:nil notificationText:notificationText completion:nil];
				
				updatedDialog.lastMessageText = notificationText;
				[weakSelf performSegueWithIdentifier:kGoToChatSegueIdentifier sender:updatedDialog];
				[SVProgressHUD dismiss];
			}
			else {
				[SVProgressHUD showErrorWithStatus:@"Can not update dialog"];
			}
		}];
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
	NSString *message = [NSString stringWithFormat:@"%@ added ", [QBSession currentSession].currentUser.login];
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

@end
