//
//  DialogsViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogsViewController.h"
#import "DialogsSelectionVC.h"
#import "CreateNewDialogViewController.h"
#import "UIViewController+InfoScreen.h"
#import "CacheManager.h"
#import "SVProgressHUD.h"
#import "Profile.h"
#import "MenuViewController.h"
#import "VideoSettingsViewController.h"
#import "AudioSettingsViewController.h"
#import "NSString+Chat.h"
#import "UIViewController+Alert.h"

@interface DialogsViewController () <ChatManagerDelegate, QBChatDelegate, ChatManagerConnectionDelegate>
//MARK: - Properties
@end

@implementation DialogsViewController

- (void)setupDialogs {
    self.chatManager.delegate = self;
    self.chatManager.connectionDelegate = self;
    [self.chatManager updateStorage];
    
    UILongPressGestureRecognizer *tapGestureDelete = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapEdit:)];
    tapGestureDelete.minimumPressDuration = 0.3;
    tapGestureDelete.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:tapGestureDelete];
}

- (void)setupNavigationBar {
    Profile *profile = [[Profile alloc] init];
    NSString *fullName = profile.fullName;
    NSUInteger ID = profile.ID;
    if (QBSession.currentSession.currentUser) {
        QBUUser *currentUser = QBSession.currentSession.currentUser;
        fullName = currentUser.fullName;
        ID = currentUser.ID;
    }
    
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [fullName stringByTrimmingCharactersInSet:characterSet];
    NSString * firstLetter = name.firstLetter;
    
    UIButton *profileBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28.0f, 28.0f)];
    profileBarButton.titleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightSemibold];
    [profileBarButton setTitle:firstLetter forState:UIControlStateNormal];
    [profileBarButton setTitle:firstLetter forState:UIControlStateHighlighted];
    profileBarButton.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
    (unsigned long)ID]];
    profileBarButton.layer.cornerRadius = 14.0f;
    [profileBarButton addTarget:self action:@selector(didTapMenu:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:profileBarButton];
    menuItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem = menuItem;
    
    
    UIBarButtonItem *usersButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(didTapNewChat:)];
    self.navigationItem.rightBarButtonItem = usersButtonItem;
    usersButtonItem.tintColor = UIColor.whiteColor;
}

- (void)setupNavigationTitle {
    self.navigationItem.title = QBSession.currentSession.currentUser.fullName;
}

#pragma mark - Actions
- (void)didTapMenu:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    MenuViewController *actionsMenuVC = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    actionsMenuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    actionsMenuVC.menuType = TypeMenuAppMenu;

    __weak __typeof(self) weakSelf = self;
    
    QBUUser *currentUser = QBSession.currentSession.currentUser;
    
    MenuAction *userProfileAction = [[MenuAction alloc] initWithTitle:currentUser.name.capitalizedString action:ChatActionUserProfile handler:^(ChatAction action) {
        NSLog(@"User Profile");
    }];
    
    MenuAction *videoConfigAction = [[MenuAction alloc] initWithTitle:@"Video Configuration" action:ChatActionVideoConfig handler:^(ChatAction action) {
        __typeof(weakSelf)strongSelf = weakSelf;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        VideoSettingsViewController *videoSettingsVC = [storyboard instantiateViewControllerWithIdentifier:@"VideoSettingsViewController"];
        [strongSelf.navigationController pushViewController:videoSettingsVC animated:YES];
    }];
    
    MenuAction *audioConfigAction = [[MenuAction alloc] initWithTitle:@"Audio Configuration" action:ChatActionAudioConfig handler:^(ChatAction action) {
        __typeof(weakSelf)strongSelf = weakSelf;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        AudioSettingsViewController *audioSettingsVC = [storyboard instantiateViewControllerWithIdentifier:@"AudioSettingsViewController"];
        [strongSelf.navigationController pushViewController:audioSettingsVC animated:YES];
    }];
    
    MenuAction *appInfoAction = [[MenuAction alloc] initWithTitle:@"App Info" action:ChatActionAppInfo handler:^(ChatAction action) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:@"PresentInfoViewController" sender:nil];
    }];
    
    MenuAction *logoutAction = [[MenuAction alloc] initWithTitle:@"Logout" action:ChatActionLogout handler:^(ChatAction action) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf didTapLogout];
    }];

    [actionsMenuVC addAction:logoutAction];
    [actionsMenuVC addAction:appInfoAction];
    [actionsMenuVC addAction:audioConfigAction];
    [actionsMenuVC addAction:videoConfigAction];
    [actionsMenuVC addAction:userProfileAction];

    [self presentViewController:actionsMenuVC animated:NO completion:nil];
}

- (void)tapEdit:(UILongPressGestureRecognizer *)gestureReconizer {
    if (gestureReconizer.state == UIGestureRecognizerStateEnded) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsSelectionVC *deleteVC = [storyboard instantiateViewControllerWithIdentifier:@"DialogsSelectionVC"];
    if (deleteVC) {
        deleteVC.action = ChatActionDelete;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:deleteVC];
        navVC.navigationBar.barTintColor = UIColor.mainColor;
        navVC.navigationBar.barStyle = UIBarStyleBlack;
        [navVC.navigationBar setTranslucent:NO];
        navVC.navigationBar.tintColor = UIColor.whiteColor;
        navVC.navigationBar.shadowImage = [UIImage imageNamed:@"navbar-shadow"];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:NO completion:^{
            [self.tableView removeGestureRecognizer:gestureReconizer];
        }];
    }
}

- (void)didTapNewChat:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    CreateNewDialogViewController *createNewDialogVC = [storyboard instantiateViewControllerWithIdentifier:@"CreateNewDialogViewController"];
    [self.navigationController pushViewController:createNewDialogVC animated:YES ];
}

#pragma mark Logout
- (void)didTapLogout {
    [SVProgressHUD showWithStatus:@"Logouting..."];
    __weak __typeof(self)weakSelf = self;
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf.chatManager breakConnectionWithCompletion:^{
            [SVProgressHUD dismiss];
            [weakSelf.chatManager deactivateAutomaticMode];
            [Profile clear];
            [weakSelf.chatManager.storage clear];
            [CacheManager.instance clearCache];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:kToken];
            if (self.onSignIn) {
                self.onSignIn();
            }
            [SVProgressHUD showSuccessWithStatus:@"Complited"];
        }];
    }];
}

- (void)deleteLastSubscriptionWithCompletion:(void(^)(void))completion {
    NSNumber *lastSubscriptionId = [NSUserDefaults.standardUserDefaults objectForKey:kSubscriptionID];
    if (lastSubscriptionId == nil) {
        if (completion) { completion(); }
        return;
    }
    
    [QBRequest deleteSubscriptionWithID:lastSubscriptionId.unsignedIntValue
                           successBlock:^(QBResponse * _Nonnull response) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kSubscriptionID];
        Log(@"[%@] Delete Subscription request - Success",  NSStringFromClass(DialogsViewController.class));
        if (completion) { completion(); }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Delete Subscription request - Error",  NSStringFromClass(DialogsViewController.class));
        if (completion) { completion(); }
    }];
}

- (void)tableView:(UITableView *)tableView
         configureCell:(DialogCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    tableView.allowsMultipleSelection = NO;
    cell.checkBoxImageView.hidden = YES;
    cell.checkBoxView.hidden = YES;
    cell.lastMessageDateLabel.hidden = NO;
    cell.contentView.backgroundColor = UIColor.clearColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (self.openChatScreen) {
        self.openChatScreen(dialog, NO);
    }
}

#pragma mark QBChatDelegate
- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    [self.chatManager updateDialogWith:dialogID withMessage:message];
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message {
    if ([self.chatManager.storage dialogWithID:message.dialogID]) {
        return;
    }
    [self.chatManager updateDialogWith:message.dialogID withMessage:message];
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [self reloadContent];
    [QBChat.instance addDelegate: self];
    [SVProgressHUD dismiss];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [self reloadContent];
    [SVProgressHUD dismiss];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    if (self.navigationController.topViewController == self) {
        [SVProgressHUD show];
    }
}

//MARK: - ChatManagerConnectionDelegate
- (void)chatManagerConnect:(ChatManager *)chatManager {
    [SVProgressHUD showSuccessWithStatus:@"Connected"];
    [self.chatManager updateStorage];
}

- (void)chatManagerDisconnect:(ChatManager *)chatManager withLostNetwork:(BOOL)lostNetwork {
    if (lostNetwork == NO) { return; }
    if ([self.presentedViewController isKindOfClass:[Alert class]]) {
        Alert *alert = (Alert *)self.presentedViewController;
        if (alert.isPresented) {
            return;
        }
    }
    [self showAlertWithTitle:@"No Internet Connection" message:@"Make sure your device is connected to the internet" fromViewController:self];
}

@end
