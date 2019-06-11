//
//  DialogsViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogsViewController.h"
#import "ChatViewController.h"
#import <Quickblox/QBASession.h>
#import "DialogTableViewCell.h"
#import "UIViewController+InfoScreen.h"
#import "ChatManager.h"
#import "Profile.h"
#import "Constants.h"
#import "Log.h"
#import "QBUUser+Chat.h"

@interface DialogsViewController () <ChatManagerDelegate, QBChatDelegate>


@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, strong) NSArray *dialogs;
@property (nonatomic, strong) ChatManager *chatManager;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logoutButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New Chat"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didTapNewChat:)];
    
    [self showInfoButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.chatManager.delegate = self;
    if ([QBChat.instance isConnected]) {
        [self.chatManager updateStorage];
    }
}

#pragma mark - Actions
- (void)didTapNewChat:(UIButton *)sender {
    [self performSegueWithIdentifier:kGoToAddOccupantsSegueIdentifier sender:nil];
}

- (void)logoutButtonPressed:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
        return;
    }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOGOUTING", nil) maskType:SVProgressHUDMaskTypeClear];
    
#if TARGET_OS_SIMULATOR
    [self disconnectUser];
#else
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [QBRequest subscriptionsWithSuccessBlock:^(QBResponse * _Nonnull response, NSArray<QBMSubscription *> * _Nullable objects) {
        if ([objects.firstObject.deviceUDID isEqualToString:deviceIdentifier]) {
            [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
                
                [self disconnectUser];
                
            } errorBlock:^(QBError *error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.error.localizedDescription];
                    return;
                }
                [SVProgressHUD dismiss];
            }];
            
        } else {
            [self disconnectUser];
        }
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
        [strongSelf.navigationController popToRootViewControllerAnimated:NO];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.error.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
    }];
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dialogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DialogTableViewCell *cell = (DialogTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"dialogcell"
                                                                                        forIndexPath:indexPath];
    
    if (indexPath.row + 1 > self.dialogs.count) return cell;
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        cell.dialogNameLabel.text = @"";
        cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
        if (chatDialog.lastMessageText.length == 0 && chatDialog.lastMessageID.length != 0) {
            cell.lastMessageTextLabel.text = @"[Attachment]";
        }
        __block QBUUser *recipient;
        recipient = [self.chatManager.storage userWithID: (NSUInteger)chatDialog.recipientID];
        if (!recipient) {
            [self.chatManager loadUserWithID:(NSUInteger)chatDialog.recipientID completion:^(QBUUser * _Nullable user) {
                recipient = user;
                cell.dialogNameLabel.text = recipient.name;
            }];
        } else {
            cell.dialogNameLabel.text = recipient.name;
        }
        cell.dialogImageView.image = [UIImage imageNamed:@"chatRoomIcon"];
        
    } else {
        cell.lastMessageTextLabel.text = chatDialog.lastMessageText;
        if (chatDialog.lastMessageText.length == 0 && chatDialog.lastMessageUserID > 0) {
            cell.lastMessageTextLabel.text = @"[Attachment]";
        }
        cell.dialogNameLabel.text = chatDialog.name;
        cell.dialogImageView.image = [UIImage imageNamed:@"GroupChatIcon"];
    }
    
    BOOL hasUnreadMessages = chatDialog.unreadMessagesCount > 0;
    cell.unreadContainerView.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString *unreadText = nil;
        if (chatDialog.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%@", @(chatDialog.unreadMessagesCount)];
        }
        cell.unreadCountLabel.text = unreadText;
    } else {
        cell.unreadCountLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog.ID];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (chatDialog.type == QBChatDialogTypePublicGroup) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (editingStyle != UITableViewCellEditingStyleDelete || dialog.type == QBChatDialogTypePublicGroup) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SA_STR_WARNING", nil) message:NSLocalizedString(@"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_DELETE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_DELETING", nil)];
        
        if (dialog.type == QBChatDialogTypePrivate) {
            [self.chatManager deleteDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
            }];
        } else {
            
            Profile *currentUser = [[Profile alloc] init];
            if (currentUser.isFull == NO) {
                return;
            }
            
            // group
            NSMutableArray<NSNumber *>  *occupantsWithoutCurrentUser =
            [NSMutableArray arrayWithArray:dialog.occupantIDs];
            [occupantsWithoutCurrentUser removeObject:@(currentUser.ID)];
            
            dialog.occupantIDs = occupantsWithoutCurrentUser;
            
            NSString *message = [NSString stringWithFormat:@"User %@ %@", currentUser.fullName, NSLocalizedString(@"SA_STR_USER_HAS_LEFT", nil)];
            // Notifies occupants that user left the dialog.
            [self.chatManager sendLeaveMessage:message toDialog:dialog completion:^(NSError * _Nullable error) {
                if (error){
                    Log(@"[%@] sendLeaveMessage error: %@",
                        NSStringFromClass([DialogsViewController class]),
                        error.localizedDescription);
                    [SVProgressHUD dismiss];
                    return;
                }
                [self.chatManager deleteDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
                    
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
- (void)reloadContent {
    self.dialogs = [[ChatManager instance].storage dialogsSortByUpdatedAt];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
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
