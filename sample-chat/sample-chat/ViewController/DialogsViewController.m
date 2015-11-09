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
@property (nonatomic, readonly) NSArray* dialogs;

@end

@implementation DialogsViewController

- (void)viewDidLoad {
    [ServicesManager.instance.chatService addDelegate:self];
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     if (![[QBChat instance] isConnected]) {
                                                                                         [SVProgressHUD showWithStatus:@"Connecting to the chat..." maskType:SVProgressHUDMaskTypeClear];
                                                                                     }
                                                                                 }];
    
    if ([QBChat instance].isConnected) {
        [self loadDialogs];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Logged in as %@", [QBSession currentSession].currentUser.login];
	[self.tableView reloadData];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeClear];
    
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
            [weakSelf performSegueWithIdentifier:@"kBackToLoginViewController" sender:nil];
            [SVProgressHUD showSuccessWithStatus:@"Logged out!"];
        }];
    });
}

- (void)loadDialogs
{
    __weak __typeof(self) weakSelf = self;
    if ([ServicesManager instance].lastActivityDate != nil) {
        [[ServicesManager instance] joinAllGroupDialogs];
        [[ServicesManager instance].chatService fetchDialogsUpdatedFromDate:[ServicesManager instance].lastActivityDate andPageLimit:kDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            //
            __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.tableView reloadData];
        } completionBlock:^(QBResponse *response) {
            //
            if ([ServicesManager instance].isAuthorized && response.success) {
                [ServicesManager instance].lastActivityDate = [NSDate date];
            }
        }];
    }
    else {
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
        [[ServicesManager instance].chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.tableView reloadData];
        } completion:^(QBResponse *response) {
            if ([ServicesManager instance].isAuthorized) {
                if (response.success) {
                    [SVProgressHUD showSuccessWithStatus:@"Completed"];
                    [ServicesManager instance].lastActivityDate = [NSDate date];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:@"Failed to load dialogs"];
                }
            }
        }];
    }
}

- (NSArray *)dialogs
{
    // Retrieving dialogs sorted by updatedAt date from memory storage.
	return [ServicesManager.instance.chatService.dialogsMemoryStorage dialogsSortByUpdatedAtWithAscending:NO];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dialogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        NSString* unreadText = nil;
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
															[SVProgressHUD showErrorWithStatus:@"Can not delete dialog"];
															NSLog(@"can not delete dialog: %@", response.error);
														}
                                                    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = self.dialogs[indexPath.row];

    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* chatViewController = segue.destinationViewController;
        chatViewController.dialog = sender;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        QBChatDialog *chatDialog = self.dialogs[indexPath.row];

        // remove current user from occupants
        NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
        for (NSNumber *identifier in chatDialog.occupantIDs) {
            if (![identifier isEqualToNumber:@(ServicesManager.instance.currentUser.ID)]) {
                [occupantsWithoutCurrentUser addObject:identifier];
            }
        }
        chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
        
        
        [SVProgressHUD showWithStatus:@"Leaving dialog..." maskType:SVProgressHUDMaskTypeClear];
        
        if (chatDialog.type == QBChatDialogTypeGroup) {
            __weak __typeof(self) weakSelf = self;
            // Notifying user about updated dialog - user left it.
            [[ServicesManager instance].chatService notifyAboutUpdateDialog:chatDialog
                                                  occupantsCustomParameters:nil
                                                           notificationText:[NSString stringWithFormat:@"%@ has left dialog!", [ServicesManager instance].currentUser.login]
                                                                 completion:^(NSError *error) {
                                                                     NSAssert(error == nil, @"Problems while leaving dialog!");
                                                                     [weakSelf deleteDialogWithID:chatDialog.ID];
                                                                 }];
        } else {
            [self deleteDialogWithID:chatDialog.ID];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave";
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

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat connected!" maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat reconnected!" maskType:SVProgressHUDMaskTypeClear];
    [self loadDialogs];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService
{
    [SVProgressHUD showErrorWithStatus:@"Chat disconnected!"];
}

- (void)chatServiceChatDidNotLoginWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Did not login with error: %@", [error description]]];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Chat failed with error: %@", [error description]]];
}

@end
