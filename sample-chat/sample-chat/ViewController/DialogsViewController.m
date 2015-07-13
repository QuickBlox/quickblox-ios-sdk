//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"

#import <Quickblox/QBASession.h>
#import "QBServicesManager.h"
#import "EditDialogTableViewController.h"
#import "ChatViewController.h"

@interface DialogsViewController ()
<
QMChatServiceDelegate,
SWTableViewCellDelegate,
QMAuthServiceDelegate,
QMChatConnectionDelegate
>

@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, readonly) NSArray* dialogs;

@end

@implementation DialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self loadDialogs];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	__weak __typeof(self)weakSelf = self;
    
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
		[strongSelf loadDialogs];
	}];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome, %@", [QBSession currentSession].currentUser.login];
    
    [QBServicesManager.instance.chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[QBServicesManager instance].chatService removeDelegate:self];
}

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeClear];
    [[QBServicesManager instance] logoutWithCompletion:^{
        [self performSegueWithIdentifier:@"kBackToLoginViewController" sender:nil];
        [SVProgressHUD showSuccessWithStatus:@"Logged out!"];
    }];
}

- (void)loadDialogs
{
	BOOL shouldShowSuccessStatus = NO;
	if ([self dialogs].count == 0) {
		shouldShowSuccessStatus = YES;
		[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
	}
	
    __weak __typeof(self) weakSelf = self;
    [QBServicesManager.instance.chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        __typeof(self) strongSelf = weakSelf;
        if (response.error != nil) {
            [SVProgressHUD showErrorWithStatus:@"Can not download"];
        }
        
        for (QBChatDialog* dialog in dialogObjects) {
            if (dialog.type != QBChatDialogTypePrivate) {
                [[QBServicesManager instance].chatService joinToGroupDialog:dialog failed:^(NSError *error) {
                    NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }];
            }
        }
        [strongSelf.tableView reloadData];
    } completion:^(QBResponse *response) {
        if (shouldShowSuccessStatus) {
            [SVProgressHUD showSuccessWithStatus:@"Completed"];
        }
    }];
}

- (NSArray *)dialogs
{
	return [QBServicesManager.instance.chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dialogs.count;
}

- (SWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell *cell = (SWTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate: {
            cell.detailTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [QBServicesManager.instance.usersService userWithID:@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
            cell.imageView.image = [UIImage imageNamed:@"chatRoomIcon"];
        }
            break;
        case QBChatDialogTypeGroup: {
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup: {
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
            
        default:
            break;
    }
    
    // set unread badge
    UILabel *badgeLabel = (UILabel *)[cell.contentView viewWithTag:201];
    if (chatDialog.unreadMessagesCount > 0) {
        badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        badgeLabel.hidden = NO;
        
        badgeLabel.layer.cornerRadius = 10;
        badgeLabel.layer.borderColor = [[UIColor blueColor] CGColor];
        badgeLabel.layer.borderWidth = 1;
    } else {
        badgeLabel.hidden = YES;
    }

	UIButton *deleteButton = [[UIButton alloc] init];
	[deleteButton setTitle:@"delete" forState:UIControlStateNormal];
	deleteButton.backgroundColor = [UIColor redColor];
	
	cell.rightUtilityButtons = @[deleteButton];
	cell.delegate = self;

    return cell;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
	QBChatDialog *chatDialog = self.dialogs[cell.tag];
	
	if (index == 0) {
		// remove current user from occupants
		NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
		for( NSNumber *identifier in chatDialog.occupantIDs ) {
			if( ![identifier isEqualToNumber:@(QBServicesManager.instance.currentUser.ID)] ) {
				[occupantsWithoutCurrentUser addObject:identifier];
			}
		}
		chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];

		[cell hideUtilityButtonsAnimated:YES];
		
		[SVProgressHUD showWithStatus:@"Deleting dialog..." maskType:SVProgressHUDMaskTypeClear];
		
		if( chatDialog.type == QBChatDialogTypeGroup ) {
			__weak __typeof(self) weakSelf = self;
			[[QBServicesManager instance].chatService notifyAboutUpdateDialog:chatDialog
													occupantsCustomParameters:nil
															 notificationText:[NSString stringWithFormat:@"%@ has left dialog!", [QBServicesManager instance].currentUser.login]
																   completion:^(NSError *error) {
																	   NSAssert(error == nil, @"Problems while deleting dialog!");
																	   [weakSelf deleteDialogWithID:chatDialog.ID];
																   }];
		}
		else {
			[self deleteDialogWithID:chatDialog.ID];
		}

	}
}

- (void)deleteDialogWithID:(NSString *)dialogID {
	__weak __typeof(self) weakSelf = self;
	[QBServicesManager.instance.chatService deleteDialogWithID:dialogID
													completion:^(QBResponse *response) {
														if( response.success ){
															__typeof(self) strongSelf = weakSelf;
															[strongSelf.tableView reloadData];
															[SVProgressHUD dismiss];
														}
														else{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController* chatViewController = segue.destinationViewController;
        chatViewController.dialog = sender;
    }
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
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat reconnected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService
{
    [SVProgressHUD showErrorWithStatus:@"Chat disconnected!"];
}

- (void)chatServiceChatDidLogin
{
    [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
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
