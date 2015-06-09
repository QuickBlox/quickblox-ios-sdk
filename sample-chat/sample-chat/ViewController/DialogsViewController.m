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

@interface DialogsViewController () <QMChatServiceDelegate, SWTableViewCellDelegate>
@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@end

@implementation DialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[QBServicesManager.instance.chatService addDelegate:self];
	
	[self loadDialogs];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	__weak __typeof(self)weakSelf = self;
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification *note) {
		[weakSelf loadDialogs];
	}];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[QBServicesManager.instance.chatService removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
}

- (void)loadDialogs {
	
	BOOL shouldShowSuccessStatus = NO;
	if( [[self dialogs] count] == 0 ) {
		shouldShowSuccessStatus = YES;
		[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
	}
	
    [QBServicesManager.instance.chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil interationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
		
		if( response.error != nil ) {
			[SVProgressHUD showErrorWithStatus:@"Can not download"];
		}
		
	} completion:^(QBResponse *response) {
		if( shouldShowSuccessStatus ) {
			[SVProgressHUD showSuccessWithStatus:@"Completed"];
		}
	}];
}

- (NSArray *)dialogs {
	return QBServicesManager.instance.chatService.dialogsMemoryStorage.unsortedDialogs;
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self dialogs].count;
}

- (SWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWTableViewCell *cell = (SWTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = [self dialogs][indexPath.row];
    cell.tag  = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate: {
            cell.detailTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [QBServicesManager.instance.usersService userWithID:@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
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
	
	UIButton *editChatButton = [[UIButton alloc] init];
	[editChatButton setTitle:@"edit" forState:UIControlStateNormal];
	editChatButton.backgroundColor = [UIColor blueColor];
	
	cell.rightUtilityButtons = @[deleteButton, editChatButton];
	cell.delegate = self;

    return cell;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
	QBChatDialog *chatDialog = [self dialogs][cell.tag];
	
	if (index == 0) {
		// delete
		[QBServicesManager.instance.chatService deleteDialogWithID:chatDialog.ID completion:^(QBResponse *response) {
			
		}];
	} else if (index == 1) {
		// edit
		[self performSegueWithIdentifier:kGoToEditDialogSegueIdentifier sender:chatDialog];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = [self dialogs][indexPath.row];
	// perform segue to Chat VC
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:kGoToEditDialogSegueIdentifier]) {
		EditDialogTableViewController *vc = (EditDialogTableViewController *) segue.destinationViewController;
		vc.dialog = (QBChatDialog *)sender;
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

@end
