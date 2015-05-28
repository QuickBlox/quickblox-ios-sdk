//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

#import <Quickblox/QBASession.h>
#import "QBServicesManager.h"

@interface DialogsViewController () <QMChatServiceDelegate>
@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@end

@implementation DialogsViewController

const NSUInteger kDialogsPageLimit = 10;

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[QBServicesManager.instance.chatService addDelegate:self];
	
	[self loadDialogs];
	
	__weak __typeof(self)weakSelf = self;
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification *note) {
		[weakSelf loadDialogs];
	}];
}

- (void)loadDialogs {
	
	BOOL shouldShowSuccessStatus = NO;
	if( [[self dialogs] count] == 0 ) {
		shouldShowSuccessStatus = YES;
		[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
	}
	
	[QBServicesManager.instance.chatService allDialogsWithPageLimit:kDialogsPageLimit interationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
		
		if( response.error != nil ) {
			[SVProgressHUD showErrorWithStatus:@"Can not download"];
		}
		
	} completion:^(QBResponse *response) {
		if( shouldShowSuccessStatus ) {
			[SVProgressHUD showSuccessWithStatus:@"Completed"];
		}
	}];
}

- (NSArray *)dialogs{
	return QBServicesManager.instance.chatService.dialogsMemoryStorage.unsortedDialogs;
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self dialogs] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = [self dialogs][indexPath.row];
    cell.tag  = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [QBServicesManager.instance.usersService userWithID:@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.login;
        }
            break;
        case QBChatDialogTypeGroup:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup:{
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
    if( chatDialog.unreadMessagesCount > 0 ) {
        badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        badgeLabel.hidden = NO;
        
        badgeLabel.layer.cornerRadius = 10;
        badgeLabel.layer.borderColor = [[UIColor blueColor] CGColor];
        badgeLabel.layer.borderWidth = 1;
    }
	else {
        badgeLabel.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	QBChatDialog *dialog = [self dialogs][indexPath.row];
	// perform segue to Chat VC
}


#pragma mark
#pragma Notifications

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
	[self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
	[self.tableView reloadData];
}

- (void)dealloc {
	[QBServicesManager.instance.chatService removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
}

@end
