//
//  DialogsViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogsViewController.h"
#import "DialogsSelectionVC.h"
#import "ChatViewController.h"
#import <Quickblox/QBASession.h>
#import "DialogCell.h"
#import "DialogTableViewCell.h"
#import "UIViewController+InfoScreen.h"
#import "ChatManager.h"
#import "Profile.h"
#import "Constants.h"
#import "Log.h"
#import "QBUUser+Chat.h"
#import "NSDate+Chat.h"
#import "UIColor+Chat.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "RootParentVC.h"
#import "CacheManager.h"
#import "SVProgressHUD.h"
#import <UserNotifications/UserNotifications.h>
#import "UIViewController+Alert.h"

@interface DialogsViewController () <ChatManagerDelegate, QBChatDelegate>
//MARK: - Properties
@property (nonatomic, strong) NSArray<QBChatDialog *> *dialogs;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) Boolean cancel;

@end

@implementation DialogsViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull) {
        self.navigationItem.title = currentUser.fullName;
    }
    
    self.chatManager = [ChatManager instance];
    
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
    
    [self registerForRemoteNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadContent];
    self.chatManager.delegate = self;
    
    UILongPressGestureRecognizer *tapGestureDelete = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapEdit:)];
    tapGestureDelete.minimumPressDuration = 0.3;
    tapGestureDelete.delaysTouchesBegan = YES;
    [self.tableView addGestureRecognizer:tapGestureDelete];
    
    // Reachability
    void (^updateLoginInfo)(NetworkStatus status) = ^(NetworkStatus status) {
        if (status == NetworkStatusNotReachable) {
            [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                             message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
                  fromViewController:self];
        } else {
            [self.chatManager updateStorage];
        }
    };
    
    Reachability.instance.networkStatusBlock = ^(NetworkStatus status) {
        updateLoginInfo(status);
    };
    
    updateLoginInfo(Reachability.instance.networkStatus);
}

#pragma mark - Public Methods
- (void)openChatWithDialogID:(NSString *)dialogID {
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialogID];
}

#pragma mark - Actions
- (void)tapEdit:(UILongPressGestureRecognizer *)gestureReconizer {
    if (gestureReconizer.state != UIGestureRecognizerStateEnded) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
        DialogsSelectionVC *deleteVC = [storyboard instantiateViewControllerWithIdentifier:@"DialogsSelectionVC"];
        
        if (deleteVC) {
            deleteVC.action = ChatActionsDelete;
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
}

- (void)didTapNewChat:(UIButton *)sender {
    [self performSegueWithIdentifier:kGoToAddOccupantsSegueIdentifier sender:nil];
}

#pragma mark Logout
- (void)logoutButtonPressed:(UIButton *)sender {
    if (Reachability.instance.networkStatus == NetworkStatusNotReachable) {
        [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                         message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
              fromViewController:self];
        [SVProgressHUD dismiss];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOGOUTING", nil)];
    
#if TARGET_OS_SIMULATOR
    [self disconnectUser];
#else
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [QBRequest subscriptionsWithSuccessBlock:^(QBResponse * _Nonnull response, NSArray<QBMSubscription *> * _Nullable objects) {
        for (QBMSubscription *subscription in objects) {
            if ([subscription.deviceUDID isEqualToString:deviceIdentifier] && subscription.notificationChannel == QBMNotificationChannelAPNS) {
                [self unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier];
                return;
            }
        }
        [self disconnectUser];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.status == 404) {
            [self disconnectUser];
        }
    }];
#endif
    
}

- (void)disconnectUser {
    [QBChat.instance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        [self logOut];
    }];
}

- (void)logOut {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        //ClearProfile
        [Profile clearProfile];
        [strongSelf.chatManager.storage clear];
        [CacheManager.instance clearCache];
        [(RootParentVC *)[self shared].window.rootViewController showLoginScreen];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.error.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
    }];
}

- (void)unregisterSubscriptionForUniqueDeviceIdentifier:(NSString *)deviceIdentifier {
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
        
        [self disconnectUser];
        
    } errorBlock:^(QBError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.error.localizedDescription];
            return;
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dialogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DialogCell *cell = (DialogCell *) [tableView dequeueReusableCellWithIdentifier:@"DialogCell"
                                                                      forIndexPath:indexPath];
    
    if (indexPath.row + 1 > self.dialogs.count) return cell;
    
    cell.exclusiveTouch = YES;
    cell.contentView.exclusiveTouch = YES;
    cell.tag = indexPath.row;
    tableView.allowsMultipleSelection = NO;
    cell.checkBoxImageView.hidden = YES;
    cell.checkBoxView.hidden = YES;
    cell.unreadMessageCounterLabel.hidden = NO;
    cell.unreadMessageCounterHolder.hidden = NO;
    cell.lastMessageDateLabel.hidden = NO;
    cell.contentView.backgroundColor = UIColor.clearColor;
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    
    if (chatDialog.lastMessageDate) {
        cell.lastMessageDateLabel.text = [self setupDate:chatDialog.lastMessageDate];
    } else {
        cell.lastMessageDateLabel.text = [self setupDate:chatDialog.updatedAt];
    }
    
    BOOL hasUnreadMessages = chatDialog.unreadMessagesCount > 0;
    cell.unreadMessageCounterHolder.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString *unreadText = nil;
        if (chatDialog.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%@", @(chatDialog.unreadMessagesCount)];
        }
        cell.unreadMessageCounterLabel.text = unreadText;
    } else {
        cell.unreadMessageCounterLabel.text = nil;
    }
    
    cell.dialogLastMessage.text = chatDialog.lastMessageText;
    if (chatDialog.lastMessageText.length == 0 && chatDialog.lastMessageID.length != 0) {
        cell.dialogLastMessage.text = @"[Attachment]";
    }
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        cell.dialogName.text = @"";
        __block QBUUser *recipient;
        recipient = [self.chatManager.storage userWithID: (NSUInteger)chatDialog.recipientID];
        if (!recipient) {
            [self.chatManager loadUserWithID:(NSUInteger)chatDialog.recipientID completion:^(QBUUser * _Nullable user) {
                recipient = user;
                cell.dialogName.text = recipient.name;
            }];
        } else {
            cell.dialogName.text = recipient.name;
        }
        
    } else {
        cell.dialogName.text = chatDialog.name;
    }
    
    NSInteger time = [chatDialog.createdAt timeIntervalSince1970];
    cell.dialogAvatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                          (unsigned long)time]];
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [chatDialog.name stringByTrimmingCharactersInSet:characterSet];
    NSString *firstLetter = [name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    cell.dialogAvatarLabel.text = firstLetter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    [self openChatWithDialogID:dialog.ID];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (chatDialog.type == QBChatDialogTypePublicGroup) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (Reachability.instance.networkStatus == NetworkStatusNotReachable) {
        [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                         message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
              fromViewController:self];
        [SVProgressHUD dismiss];
        return;
    }
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (editingStyle != UITableViewCellEditingStyleDelete || dialog.type == QBChatDialogTypePublicGroup) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SA_STR_WARNING", nil) message:NSLocalizedString(@"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_DELETE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_DELETING", nil)];
        
        if (dialog.type == QBChatDialogTypePrivate) {
            [self.chatManager leaveDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
            }];
        } else {
            
            Profile *currentUser = [[Profile alloc] init];
            if (currentUser.isFull == NO) {
                return;
            }
            // group
            dialog.pullOccupantsIDs = @[@(currentUser.ID)];
            
            NSString *message = [NSString stringWithFormat:@"%@ %@", currentUser.fullName, NSLocalizedString(@"SA_STR_USER_HAS_LEFT", nil)];
            // Notifies occupants that user left the dialog.
            [self.chatManager sendLeaveMessage:message toDialog:dialog completion:^(NSError * _Nullable error) {
                if (error){
                    Log(@"[%@] sendLeaveMessage error: %@",
                        NSStringFromClass([DialogsViewController class]),
                        error.localizedDescription);
                    [SVProgressHUD dismiss];
                    return;
                }
                [self.chatManager leaveDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
                    if (response == nil) {
                        
                    }
                }];
            }];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:leaveAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"SA_STR_DELETE", nil);
}

#pragma mark - Helpers
- (AppDelegate*)shared {
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (NSString *)setupDate:(NSDate *)dateSent {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateString = @"";
    
    if ([NSCalendar.currentCalendar isDateInToday:dateSent]) {
        formatter.dateFormat = @"HH:mm";
        dateString = [formatter stringFromDate:dateSent];
    } else if ([NSCalendar.currentCalendar isDateInYesterday:dateSent] == YES) {
        dateString = @"Yesterday";
    } else if ([dateSent isHasSameComponents:NSCalendarUnitYear asDate:[NSDate date]] == YES) {
        formatter.dateFormat = @"d MMM";
        dateString = [formatter stringFromDate:dateSent];
    } else {
        formatter.dateFormat = @"d.MM.yy";
        dateString = [formatter stringFromDate:dateSent];
    }
    
    return dateString;
}

- (void)registerForRemoteNotifications {
    // Enable push notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            Log(@"%@ registerForRemoteNotifications error: %@",NSStringFromClass([DialogsViewController class]),
                error.localizedDescription);
            return;
        }
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }];
    }];
}

- (void)reloadContent {
    self.dialogs = [[ChatManager instance].storage dialogsSortByUpdatedAt];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil)]) {
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.dialogID = sender;
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

- (void)chatDidConnect {
    if ([QBChat.instance isConnected]) {
        [self.chatManager updateStorage];
    }
}

- (void)chatDidReconnect {
    if ([QBChat.instance isConnected]) {
        [self.chatManager updateStorage];
    }
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

@end
