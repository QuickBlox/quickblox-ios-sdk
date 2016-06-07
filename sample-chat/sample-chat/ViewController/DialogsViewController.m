//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"

#import <Quickblox/QBASession.h>
#import "ServicesManager.h"
#import "EditDialogTableViewController.h"
#import "ChatViewController.h"
#import "DialogTableViewCell.h"

@interface DialogsViewController ()
<
QMChatServiceDelegate,
QMAuthServiceDelegate,
QMChatConnectionDelegate
>

@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, readonly) NSArray *dialogs;

@end

@implementation DialogsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
    [[ServicesManager instance].chatService addDelegate:self];
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     if (![[QBChat instance] isConnected]) {
                                                                                         [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_CONNECTING_TO_CHAT", nil) maskType:SVProgressHUDMaskTypeClear];
                                                                                     }
                                                                                 }];
    
    if ([ServicesManager instance].isAuthorized) {
        [self loadDialogs];
    }
     self.navigationItem.title = [ServicesManager instance].currentUser.login;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
   
	[self.tableView reloadData];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOGOUTING", nil) maskType:SVProgressHUDMaskTypeClear];
    
    if (![[QBChat instance] isConnected]) {
        
        [SVProgressHUD showErrorWithStatus:@"You're not connected to the chat."];
        return;
    }
    
    dispatch_group_t logoutGroup = dispatch_group_create();
    dispatch_group_enter(logoutGroup);
    // unsubscribing from pushes
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
        //
        dispatch_group_leave(logoutGroup);
    } errorBlock:^(QBError *error) {
        //
        dispatch_group_leave(logoutGroup);
    }];
    
    // resetting last activity date
    [ServicesManager instance].lastActivityDate = nil;
    
    __weak __typeof(self)weakSelf = self;
    dispatch_group_notify(logoutGroup,dispatch_get_main_queue(),^{
        // logging out
        [[QMServicesManager instance] logoutWithCompletion:^{
            
            __typeof(self) strongSelf = weakSelf;
            
            [[NSNotificationCenter defaultCenter] removeObserver:strongSelf.observerDidBecomeActive];
            strongSelf.observerDidBecomeActive = nil;
            
            [strongSelf performSegueWithIdentifier:@"kBackToLoginViewController" sender:nil];
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
        }];
    });
}

- (void)loadDialogs {
    __weak __typeof(self) weakSelf = self;
	
    if ([ServicesManager instance].lastActivityDate != nil) {
        [[ServicesManager instance].chatService fetchDialogsUpdatedFromDate:[ServicesManager instance].lastActivityDate andPageLimit:kDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            //
            [weakSelf.tableView reloadData];
        } completionBlock:^(QBResponse *response) {
            //
            if ([ServicesManager instance].isAuthorized && response.success) {
                [ServicesManager instance].lastActivityDate = [NSDate date];
            }
        }];
    }
    else {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_DIALOGS", nil) maskType:SVProgressHUDMaskTypeClear];
        [[ServicesManager instance].chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            [weakSelf.tableView reloadData];
        } completion:^(QBResponse *response) {
            if ([ServicesManager instance].isAuthorized) {
                if (response.success) {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
                    [ServicesManager instance].lastActivityDate = [NSDate date];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_FAILED_LOAD_DIALOGS", nil)];
                }
            }
        }];
    }
}

- (NSArray *)dialogs {
    // Retrieving dialogs sorted by updatedAt date from memory storage.
	return [ServicesManager.instance.chatService.dialogsMemoryStorage dialogsSortByUpdatedAtWithAscending:NO];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dialogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DialogTableViewCell *cell = (DialogTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate: {
            cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:chatDialog.recipientID];
            cell.dialogNameLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
            cell.dialogImageView.image = [UIImage imageNamed:@"chatRoomIcon"];
        }
            break;
        case QBChatDialogTypeGroup: {
            cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
            cell.dialogNameLabel.text = chatDialog.name;
            cell.dialogImageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup: {
            cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
            cell.dialogNameLabel.text = chatDialog.name;
            cell.dialogImageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
            
        default:
            break;
    }
    
    BOOL hasUnreadMessages = chatDialog.unreadMessagesCount > 0;
    cell.unreadContainerView.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString *unreadText = nil;
        if (chatDialog.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        }
        cell.unreadCountLabel.text = unreadText;
    } else {
        cell.unreadCountLabel.text = nil;
    }
	
    return cell;
}

- (void)deleteDialogWithID:(NSString *)dialogID {
	__weak __typeof(self) weakSelf = self;
    // Deleting dialog from Quickblox and cache.
	[ServicesManager.instance.chatService deleteDialogWithID:dialogID
                                                  completion:^(QBResponse *response) {
														if (response.success) {
															__typeof(self) strongSelf = weakSelf;
															[strongSelf.tableView reloadData];
															[SVProgressHUD dismiss];
														} else {
															[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR_DELETING", nil)];
															NSLog(@"can not delete dialog: %@", response.error);
														}
                                                    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = self.dialogs[indexPath.row];

    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.dialog = sender;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	
	QBChatDialog *chatDialog = self.dialogs[indexPath.row];
	
	// remove current user from occupants
	NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
	for (NSNumber *identifier in chatDialog.occupantIDs) {
		if (![identifier isEqualToNumber:@(ServicesManager.instance.currentUser.ID)]) {
			[occupantsWithoutCurrentUser addObject:identifier];
		}
	}
	chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_DELETING", nil) maskType:SVProgressHUDMaskTypeClear];
	
	if (chatDialog.type == QBChatDialogTypeGroup) {
		NSString *notificationText = [NSString stringWithFormat:@"%@ %@", [ServicesManager instance].currentUser.login, NSLocalizedString(@"SA_STR_USER_HAS_LEFT", nil)];
		__weak __typeof(self) weakSelf = self;
		
		// Notifying user about updated dialog - user left it.
		[[ServicesManager instance].chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:notificationText completion:^(NSError  *error) {
			[weakSelf deleteDialogWithID:chatDialog.ID];
		}];
	}
	else {
		[self deleteDialogWithID:chatDialog.ID];
		
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"SA_STR_DELETE", nil);
}

#pragma mark -
#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray *)dialogs {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [self.tableView reloadData];
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_CONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_RECONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_DISCONNECTED", nil)];
}

- (void)chatService:(QMChatService *)chatService chatDidNotConnectWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_DID_NOT_CONNECT_ERROR", nil), [error localizedDescription]]];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SA_STR_FAILED_TO_CONNECT_WITH_ERROR", nil), [error localizedDescription]]];
}

@end
