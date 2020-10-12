//
//  DialogsSelectionVC.m
//  samplechat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "DialogsSelectionVC.h"
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
#import "TitleView.h"
#import "UIView+Chat.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

NSString *const MESSAGE_FORWARDED = @"Message forwarded";
NSString *const DELETE_CHATS = @"Delete Chats";
NSString *const KEY_MESSAGE_FORWARDED = @"origin_sender_name";

@interface DialogsSelectionVC () <ChatManagerDelegate>
//MARK: - Properties
@property (nonatomic, strong) NSArray<QBChatDialog *> *dialogs;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *selectedPaths;
@property (nonatomic, assign) NSUInteger senderID;

@end

@implementation DialogsSelectionVC
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedPaths = [NSMutableSet set];
    
    Profile *currentUser = [[Profile alloc] init];
    if (!currentUser.isFull) {
        return;
    }
    self.senderID = currentUser.ID;
    self.chatManager = [ChatManager instance];
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    [self setupNavigationTitle];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    backButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (self.action == ChatActionsDelete) {
        UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Delete"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapDelete:)];
        self.navigationItem.rightBarButtonItem = deleteButtonItem;
        deleteButtonItem.tintColor = UIColor.whiteColor;
    } else if (self.action == ChatActionsForward)  {
        UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Send"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(didTapSend:)];
        self.navigationItem.rightBarButtonItem = sendButtonItem;
        sendButtonItem.tintColor = UIColor.whiteColor;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadContent];
    self.chatManager.delegate = self;
}

#pragma mark - Actions
- (void)didTapSend:(UIButton *)sender {
    if (!self.message) {
        return;
    }
    
    [SVProgressHUD show];
    
    dispatch_group_t sendGroup = dispatch_group_create();
    
    for (NSIndexPath *indexPath in self.selectedPaths) {
        QBChatDialog *dialog = self.dialogs[indexPath.row];
        if (!dialog) {
            continue;
        }
        dispatch_group_enter(sendGroup);
        QBChatMessage *forwardedMessage = [QBChatMessage markableMessage];
        forwardedMessage.senderID = self.senderID;
        forwardedMessage.dialogID = dialog.ID;
        forwardedMessage.dateSent = [NSDate date];
        
        forwardedMessage.deliveredIDs = @[@(self.senderID)];
        forwardedMessage.readIDs = @[@(self.senderID)];
        forwardedMessage.customParameters[@"save_to_history"] = @"1";
        
        forwardedMessage.markable = YES;
        
        QBUUser *originSenderUser = [self.chatManager.storage userWithID:self.message.senderID];
        if (originSenderUser){
            forwardedMessage.customParameters[KEY_MESSAGE_FORWARDED] = originSenderUser.fullName;
        } else {
            Profile *currentUser = [[Profile alloc] init];
            forwardedMessage.customParameters[KEY_MESSAGE_FORWARDED] = currentUser.fullName;
        }
        
        if (self.message.attachments.firstObject) {
            QBChatAttachment *attachment = self.message.attachments.firstObject;
            forwardedMessage.text = @"[Attachment]";
            forwardedMessage.attachments = @[attachment];
        } else {
            forwardedMessage.text = self.message.text;
        }
        [self.chatManager sendMessage:forwardedMessage toDialog:dialog completion:^(NSError * _Nullable error) {
            dispatch_group_leave(sendGroup);
            if (error) {
                
            }
        }];
    }
    dispatch_group_notify(sendGroup, dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)didTapBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapDelete:(UIButton *)sender {
    if (Reachability.instance.networkStatus == NetworkStatusNotReachable) {
        [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                         message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
              fromViewController:self];
        [SVProgressHUD dismiss];
        return;
    }
    
    dispatch_group_t deleteGroup = dispatch_group_create();
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SA_STR_WARNING", nil) message:NSLocalizedString(@"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_DELETE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_DELETING", nil)];
        
        
        
        for (NSIndexPath *indexPath in self.selectedPaths) {
            QBChatDialog *dialog = self.dialogs[indexPath.row];
            
            if (dialog.type == QBChatDialogTypePublicGroup) {
                continue;
            } else if (dialog.type == QBChatDialogTypePrivate) {
                dispatch_group_enter(deleteGroup);
                [self.chatManager leaveDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
                    if (response == nil) {
                        [self.selectedPaths removeObject:indexPath];
                    }
                    dispatch_group_leave(deleteGroup);
                }];
                
            } else {
                
                Profile *currentUser = [[Profile alloc] init];
                if (currentUser.isFull == NO) {
                    return;
                }
                
                // group
                dialog.pullOccupantsIDs = @[@(currentUser.ID).stringValue];
                
                NSString *message = [NSString stringWithFormat:@"%@ %@", currentUser.fullName, NSLocalizedString(@"SA_STR_USER_HAS_LEFT", nil)];
                // Notifies occupants that user left the dialog.
                [self.chatManager sendLeaveMessage:message toDialog:dialog completion:^(NSError * _Nullable error) {
                    if (error){
                        Log(@"[%@] sendLeaveMessage error: %@",
                            NSStringFromClass([DialogsSelectionVC class]),
                            error.localizedDescription);
                        [SVProgressHUD dismiss];
                        return;
                    }
                    dispatch_group_enter(deleteGroup);
                    [self.chatManager leaveDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
                        
                        if (response == nil) {
                            [self.selectedPaths removeObject:indexPath];
                            
                        }
                        dispatch_group_leave(deleteGroup);
                        
                    }];
                }];
            }
        }
        dispatch_group_notify(deleteGroup, dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:leaveAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

#pragma mark - Helpers
- (void)checkNavRightBarButtonEnabled {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedPaths.count > 0;
}

- (void)reloadContent {
    self.dialogs = [[ChatManager instance].storage dialogsSortByUpdatedAt];
    [self setupNavigationTitle];
    [self.tableView reloadData];
}

- (void)setupNavigationTitle {
    NSString *title = MESSAGE_FORWARDED;
    if (self.action == ChatActionsDelete) {
        title = DELETE_CHATS;
    }
    NSString *chats = @"chat";
    if (self.selectedPaths.count > 1) {
        chats = @"chats";
    }
    NSString *numberChats = [NSString stringWithFormat:@"%@ %@ selected", @(self.selectedPaths.count), chats];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberChats];
}

#pragma mark - Table view data source
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
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    tableView.allowsMultipleSelection = YES;
    cell.checkBoxView.hidden = NO;
    cell.unreadMessageCounterLabel.hidden = YES;
    cell.unreadMessageCounterHolder.hidden = YES;
    cell.lastMessageDateLabel.hidden = YES;
    
    if ([self.selectedPaths containsObject:indexPath]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.85f green:0.89f blue:0.97f alpha:1.0f];
        cell.checkBoxImageView.hidden = NO;
        [cell.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:0.0f
                                                 color:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]
                                           borderColor:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]];
        
    } else {
        cell.contentView.backgroundColor = UIColor.clearColor;
        cell.checkBoxView.backgroundColor = UIColor.clearColor;
        [cell.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:nil
                                           borderColor:[UIColor colorWithRed:0.42f green:0.48f blue:0.57f alpha:1.0f]];
        cell.checkBoxImageView.hidden = YES;
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
    [self handleSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleSelectRowAtIndexPath:indexPath];
}

- (void)handleSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (self.action == ChatActionsDelete && dialog.type == QBChatDialogTypePublicGroup) {
        NSString *title = [NSString stringWithFormat:@"You cannot leave %@", dialog.name ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:title message:nil fromViewController:self];
        });
    } else {
        if ([self.selectedPaths containsObject:indexPath]) {
            [self.selectedPaths removeObject:indexPath];
        } else {
            [self.selectedPaths addObject:indexPath];
        }
        [self checkNavRightBarButtonEnabled];
        [self setupNavigationTitle];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (self.action != ChatActionsDelete || chatDialog.type == QBChatDialogTypePublicGroup) {
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
                        NSStringFromClass([DialogsSelectionVC class]),
                        error.localizedDescription);
                    [SVProgressHUD dismiss];
                    return;
                }
                [self.chatManager leaveDialogWithID:dialog.ID completion:^(QBResponse * _Nonnull response) {
                    if (response == nil) {
                        [self dismissViewControllerAnimated:NO completion:^{
                            
                        }];
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

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [self reloadContent];
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
}

@end
