//
//  DialogsViewController.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogsViewController.h"
#import "DialogsSelectionViewController.h"
#import "CreateNewDialogViewController.h"
#import "UIViewController+InfoScreen.h"
#import "ImageCache.h"
#import "Profile.h"
#import "UINavigationController+Appearance.h"
#import "QBChatMessage+Chat.h"
#import "UIViewController+Alert.h"
#import "ConnectionModule.h"
#import "NotificationsProvider.h"

@interface DialogsViewController () <ChatManagerDelegate, QBChatDelegate>
//MARK: - Properties
@property (nonatomic, strong) Profile *profile;
@property (strong, nonatomic) ConnectionModule *connection;
@property (assign, nonatomic) BOOL isPresentAlert;
@end

NSString *const kStillConnection = @"Still in connecting state, please wait";

@implementation DialogsViewController

- (ConnectionModule *)connection {
    if (_connection) {
        return _connection;
    }
    _connection = [[ConnectionModule alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    
    [_connection setOnAuthorize:^{
        Log(@"[%@] [connection] On Authorize",  NSStringFromClass(weakSelf.class));
        NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
        if ([userDefaults boolForKey:kNeedUpdateToken] == NO) {
            return;
        }
        NSData *token = [userDefaults objectForKey:kToken];
        if (token == nil) {
            return;
        }
        [NotificationsProvider deleteLastSubscriptionWithCompletion:^{
            [NotificationsProvider createSubscriptionWithToken:token];
        }];
    }];
    
    [_connection setOnConnect:^{
        weakSelf.isPresentAlert = NO;
        Log(@"[%@] [connection] On Connect",  NSStringFromClass(weakSelf.class));
        [weakSelf.refreshControl beginRefreshing];
        [weakSelf showAnimatedAlertWithTitle:nil message:@"Connection established" fromViewController:weakSelf];
        [weakSelf.chatManager updateStorage];
    }];
    
    [_connection setOnDisconnect:^(BOOL lostNetwork) {
        Log(@"[%@] [connection] On Disconnect",  NSStringFromClass(weakSelf.class));
        if (lostNetwork == NO || weakSelf.isPresentAlert) { return; }
        weakSelf.isPresentAlert = YES;
        [weakSelf showAnimatedAlertWithTitle:nil message:kStillConnection fromViewController:weakSelf];
    }];
    
    return _connection;
}

- (void)setupDialogs {
    [self reloadContent];
    self.profile = [[Profile alloc] init];
    self.chatManager.delegate = self;
    [self.chatManager updateStorage];
    [self.refreshControl beginRefreshing];
}

- (void)setupViews {
    self.isPresentAlert = NO;
    [self.connection activateAutomaticMode];
    UILongPressGestureRecognizer *tapGestureDelete = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapEdit:)];
    tapGestureDelete.minimumPressDuration = 0.5f;
    tapGestureDelete.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:tapGestureDelete];
    
    [QBChat.instance addDelegate:self];
    
    self.navigationItem.rightBarButtonItems = @[];
    self.navigationItem.leftBarButtonItems = @[];
    UIBarButtonItem *exitButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(logoutButtonPressed:)];
    exitButtonItem.tintColor = UIColor.whiteColor;
    
    UIBarButtonItem *emptyButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-info"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:nil];
    emptyButtonItem.tintColor = UIColor.clearColor;
    emptyButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItems = @[exitButtonItem, emptyButtonItem];
    UIBarButtonItem *usersButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(didTapNewChat:)];
    self.navigationItem.rightBarButtonItem = usersButtonItem;
    usersButtonItem.tintColor = UIColor.whiteColor;
    [self addInfoButton];
}

- (void)setupNavigationTitle {
    self.navigationItem.title = @"Chats";
}

#pragma mark - Actions

- (IBAction)refreshDialogs:(UIRefreshControl *)sender {
    [self.chatManager updateStorage];
}

- (void)tapEdit:(UILongPressGestureRecognizer *)gestureReconizer {
    if (gestureReconizer.state == UIGestureRecognizerStateEnded) {
        return;
    }
    gestureReconizer.state = UIGestureRecognizerStateEnded;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsSelectionViewController *deleteVC = [storyboard instantiateViewControllerWithIdentifier:@"DialogsSelectionVC"];
    deleteVC.action = ChatActionDelete;
    [self.navigationController pushViewController:deleteVC animated:NO];
}

- (void)didTapNewChat:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    CreateNewDialogViewController *createNewDialogVC = [storyboard instantiateViewControllerWithIdentifier:@"CreateNewDialogViewController"];
    [self.navigationController pushViewController:createNewDialogVC animated:YES ];
}

#pragma mark Logout
- (void)logoutButtonPressed:(UIButton *)sender {
    if (!self.connection.established) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [self.progressView start];
    __weak __typeof(self)weakSelf = self;
    [NotificationsProvider deleteLastSubscriptionWithCompletion:^{
        [weakSelf.connection breakConnectionWithCompletion:^{
            [weakSelf.connection deactivateAutomaticMode];
            [Profile clear];
            [weakSelf.chatManager.storage clear];
            [ImageCache.instance clearCache];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:kToken];
            [weakSelf.progressView stop];
            if (weakSelf.onSignIn) {
                weakSelf.onSignIn();
            }
        }];
    }];
}

- (void)openChatScreenWithDialogID:(NSString *)dialogID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    ChatViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.dialogID = dialogID;
    [self.navigationController pushViewController:chatVC animated:NO];
}

- (void)configureCell:(DialogCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    self.tableView.allowsMultipleSelection = NO;
    cell.checkBoxImageView.hidden = YES;
    cell.checkBoxView.hidden = YES;
    cell.lastMessageDateLabel.hidden = NO;
    cell.contentView.backgroundColor = UIColor.clearColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    [self openChatScreenWithDialogID:dialog.ID];
}

#pragma mark QBChatDelegate
- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    if (self.profile.ID == message.senderID &&
        message.isNotificationMessageTypeLeave == YES) {
        QBChatDialog *dialog = [self.chatManager.storage dialogWithID:message.dialogID];
        if (!dialog) {
            return;
        }
        NSInteger index = [self.dialogs indexOfObject:dialog];
        self.chatManager.delegate = self;
        NSMutableArray<QBChatDialog *> *arrayOfDialogs = self.dialogs.mutableCopy;
        [arrayOfDialogs removeObject:dialog];
        self.dialogs = arrayOfDialogs.copy;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        return;
    }
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message {
    if (message.dialogID && [self.chatManager.storage dialogWithID:message.dialogID]) {
        return;
    }
    if (message.isNotificationMessageTypeCreate || message.isNotificationMessageTypeAdding) {
        if (message.dialogID) {
            [self.chatManager updateDialogWith:message.dialogID withMessage:message];
        } else {
            NSString *dialogID = message.customParameters[@"dialogId"];
            if (dialogID) {
                [self.chatManager updateDialogWith:dialogID withMessage:message];
            }
        }
    }
}

- (void)chatDidConnect {
    [self.chatManager updateStorage];
    Log(@"[%@] Connected",
        NSStringFromClass([DialogsViewController class]));
}

- (void)chatDidReconnect {
    [self.chatManager updateStorage];
    Log(@"[%@] ReConnected",
        NSStringFromClass([DialogsViewController class]));
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [self.refreshControl endRefreshing];
    [self reloadContent];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [self.refreshControl endRefreshing];
    [self reloadContent];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [self.refreshControl endRefreshing];
    [self showAnimatedAlertWithTitle:nil message:message fromViewController:self];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    if (self.navigationController.topViewController == self) {
    }
}

@end
