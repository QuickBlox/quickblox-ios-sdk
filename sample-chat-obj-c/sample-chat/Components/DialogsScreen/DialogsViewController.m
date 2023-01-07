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
#import "AuthModule.h"
#import "NotificationsProvider.h"
#import "SplashScreenViewController.h"
#import "NSError+Chat.h"

@interface DialogsViewController () <ChatManagerDelegate, QBChatDelegate, AuthModuleDelegate, ConnectionModuleDelegate>
//MARK: - Properties
@property (nonatomic, strong) Profile *profile;
@property (strong, nonatomic) ConnectionModule *connection;
@property (strong, nonatomic) AuthModule *authModule;
@property (strong, nonatomic) SplashScreenViewController *splashVC;
@end

NSString *const kStillConnection = @"Still in connecting state, please wait";
NSString *const kReconnection = @"Reconnecting state, please wait";

@implementation DialogsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.authModule = [[AuthModule alloc] init];
    self.authModule.delegate = self;
    self.connection = [[ConnectionModule alloc] init];
    self.connection.delegate = self;
    if (!self.connection.established) {
        [self showSplashScreen];
    }
    [self.connection activateAutomaticMode];
    
    self.chatManager.delegate = self;
    self.profile = [[Profile alloc] init];
    [QBChat.instance addDelegate:self];
    
    UILongPressGestureRecognizer *tapGestureDelete = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapEdit:)];
    tapGestureDelete.minimumPressDuration = 0.5f;
    tapGestureDelete.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:tapGestureDelete];
}

- (void)setupDialogs {
    [self.refreshControl beginRefreshing];
    [self.chatManager updateStorage];
}

- (void)setupViews {
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
    [self logout];
}

- (void)logout {
    if (!self.connection.established) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [self.progressView start];
    __weak __typeof(self)weakSelf = self;
    [NotificationsProvider deleteLastSubscriptionWithCompletion:^{
        [weakSelf.connection breakConnectionWithCompletion:^{
            [weakSelf.authModule logout];
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

- (void)showSplashScreen {
    if (self.splashVC) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    self.splashVC = [storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"];
    self.splashVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:self.splashVC animated:NO completion:nil];
}

- (void)hideSplashScreen {
    if (!self.splashVC) {
        return;
    }
    [self.splashVC dismissViewControllerAnimated:NO completion:^{
        self.splashVC = nil;
    }];
}

#pragma mark QBChatDelegate
- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message {
    if ([self.chatManager.storage dialogWithID:message.dialogID]) {
        return;
    }
    NSString *dialogID = message.dialogID ? : message.customParameters[@"dialog_Id"];
    if (dialogID) {
        [self.chatManager updateDialogWith:dialogID withMessage:message];
    }
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [self reloadContent];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [self reloadContent];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [self.refreshControl endRefreshing];
    [self showAnimatedAlertWithTitle:nil message:message];
}

#pragma mark - AuthModuleDelegate
- (void)authModule:(AuthModule *)authModule didLoginUser:(QBUUser *)user {
    [Profile synchronizeUser:user];
    [self.connection establish];
}

- (void)authModuleDidLogout:(AuthModule *)authModule {
    [self.connection deactivateAutomaticMode];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [Profile clear];
    [self.chatManager.storage clear];
    [ImageCache.instance clearCache];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kToken];
    [self.progressView stop];
    if (self.onSignOut) {
        self.onSignOut();
    }
}

- (void)authModule:(AuthModule *)authModule didReceivedError:(NSError *)error {
    [self showUnAuthorizeAlert:error.localizedDescription logoutAction:^(UIAlertAction * _Nonnull action) {
        [self logout];
    } tryAgainAction:^(UIAlertAction * _Nonnull action) {
        [authModule loginWithFullName:self.profile.fullName login:self.profile.login];
    }];
}

#pragma mark - ConnectionModuleDelegate
- (void)connectionModuleWillConnect:(ConnectionModule *)connectionModule {
    [self showAnimatedAlertWithTitle:nil message:kStillConnection];
}

- (void)connectionModuleDidConnect:(ConnectionModule *)connectionModule {
    [self setupDialogs];
    [self hideAlertView];
    [self hideSplashScreen];
}

- (void)connectionModuleDidNotConnect:(ConnectionModule *)connectionModule withError:(NSError*)error {
    [self.refreshControl endRefreshing];
    [self hideSplashScreen];
    if (error.isNetworkError) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [self showAlertWithTitle:nil message:error.localizedDescription handler:nil];
}

- (void)connectionModuleWillReconnect:(ConnectionModule *)connectionModule {
    [self showAnimatedAlertWithTitle:nil message:kReconnection];
}

- (void)connectionModuleDidReconnect:(ConnectionModule *)connectionModule {
    [self setupDialogs];
    [self hideAlertView];
}

- (void)connectionModuleTokenHasExpired:(ConnectionModule *)connectionModule {
    [self showSplashScreen];
    [self.refreshControl endRefreshing];
    Profile *profile = [[Profile alloc] init];
    [self.authModule loginWithFullName:profile.fullName login:profile.login];
}

@end
