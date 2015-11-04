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
        [[[ServicesManager instance].usersService getUsersWithIDs:self.dialog.occupantIDs] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
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
	
	[SVProgressHUD showWithStatus:@"Creating dialog..." maskType:SVProgressHUDMaskTypeClear];
	
    // Creating group chat dialog.
	[ServicesManager.instance.chatService createGroupChatDialogWithName:[self dialogNameFromUsers:users] photo:nil occupants:users completion:^(QBResponse *response, QBChatDialog *createdDialog) {
		
		if( response.success ) {
			[SVProgressHUD dismiss];
			[ServicesManager.instance.chatService notifyUsersWithIDs:createdDialog.occupantIDs aboutAddingToDialog:createdDialog completion:nil];
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
	
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService getUsersWithIDs:usersIDs] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
        //
        // Updating dialog with occupants.
        [ServicesManager.instance.chatService joinOccupantsWithIDs:usersIDs toChatDialog:self.dialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
            if( response.success ) {
                // Notifying users about newly created dialog.
                [[ServicesManager instance].chatService notifyUsersWithIDs:usersIDs aboutAddingToDialog:updatedDialog completion:^(NSError * _Nullable error) {
                    //
                    NSString *notificationText = [weakSelf updatedMessageWithUsers:task.result];
                    // Notify occupants that dialog was updated.
                    [ServicesManager.instance.chatService notifyAboutUpdateDialog:updatedDialog occupantsCustomParameters:nil notificationText:notificationText completion:nil];
                    
                    updatedDialog.lastMessageText = notificationText;
                    [weakSelf performSegueWithIdentifier:kGoToChatSegueIdentifier sender:updatedDialog];
                    [SVProgressHUD dismiss];
                }];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Can not update dialog"];
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

#pragma mark QMChatServiceDelegate delegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
	if( [chatDialog.ID isEqualToString:self.dialog.ID] ) {
		self.dialog = chatDialog;
		[self reloadDataSource];
	}
}

@end
