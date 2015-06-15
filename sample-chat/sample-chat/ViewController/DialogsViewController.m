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

@interface DialogsViewController () <QMChatServiceDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, readonly) NSArray* dialogs;

@end

@implementation DialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[QBServicesManager.instance.chatService addDelegate:self];
	
	[self loadDialogs];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	__weak __typeof(self)weakSelf = self;
    
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
		[strongSelf loadDialogs];
	}];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome, %@", [QBSession currentSession].currentUser.login];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
}

- (void)loadDialogs
{
	BOOL shouldShowSuccessStatus = NO;
	if (self.dialogs.count == 0) {
		shouldShowSuccessStatus = YES;
		[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
	}
	
    [QBServicesManager.instance.chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil interationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        
		if (response.error != nil) {
			[SVProgressHUD showErrorWithStatus:@"Can not download"];
		}
        
        for (QBChatDialog* dialog in dialogObjects) {
            if (dialog.type != QBChatDialogTypePrivate) {
                [[QBServicesManager instance].chatService joinToGroupDialog:dialog completion:^(NSError *error) {
                    NSLog(@"");
                }];
            }
        }
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
        __typeof(self) weakSelf = self;
		[QBServicesManager.instance.chatService deleteDialogWithID:chatDialog.ID completion:^(QBResponse *response) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf.tableView reloadData];
        }];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = self.dialogs[indexPath.row];

    [self performSegueWithIdentifier:@"kShowChatViewController" sender:dialog];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kShowChatViewController"]) {
        ChatViewController* chatViewController = segue.destinationViewController;
        chatViewController.dialog = sender;
    }
}

#pragma mark
#pragma Notifications

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs
{
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog
{
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    [self.tableView reloadData];
}

@end
