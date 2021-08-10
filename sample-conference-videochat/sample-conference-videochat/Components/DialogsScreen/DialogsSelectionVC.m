//
//  DialogsSelectionVC.m
//  sample-conference-videochat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "DialogsSelectionVC.h"
#import "QBUUser+Chat.h"
#import "TitleView.h"
#import "UIView+Chat.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

NSString *const MESSAGE_FORWARDED = @"Message forwarded";
NSString *const DELETE_CHATS = @"Delete Chats";
NSString *const KEY_MESSAGE_FORWARDED = @"origin_sender_name";

@interface DialogsSelectionVC () <ChatManagerDelegate, ChatManagerConnectionDelegate>
//MARK: - Properties
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *selectedPaths;
@end

@implementation DialogsSelectionVC

- (void)setupDialogs {
    self.chatManager.delegate = self;
    self.chatManager.connectionDelegate = self;
    self.selectedPaths = [NSMutableSet set];
}

- (void)setupNavigationBar {
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;

    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    backButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (self.action == ChatActionDelete) {
        UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Delete"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapDelete:)];
        self.navigationItem.rightBarButtonItem = deleteButtonItem;
        deleteButtonItem.tintColor = UIColor.whiteColor;
    } else if (self.action == ChatActionForward)  {
        UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Send"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(didTapSend:)];
        self.navigationItem.rightBarButtonItem = sendButtonItem;
        sendButtonItem.tintColor = UIColor.whiteColor;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Actions
- (void)handleLeaveDialogsWithIndexPath:(NSIndexPath *)indexPath {
    [self.selectedPaths removeObject:indexPath];
    if (self.selectedPaths.count == 0) {
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)handleLeaveDialog {
    // configure it if necessary.
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapSend:(UIButton *)sender {
    if (!self.message) {
        return;
    }
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    QBUUser *currentUser = QBSession.currentSession.currentUser;
    
    [SVProgressHUD show];
    sender.enabled = NO;

    for (NSIndexPath *indexPath in self.selectedPaths) {
        QBChatDialog *dialog = self.dialogs[indexPath.row];
        if (!dialog) {
            continue;
        }
        QBChatMessage *forwardedMessage = [QBChatMessage markableMessage];
        forwardedMessage.senderID = currentUser.ID;
        forwardedMessage.dialogID = dialog.ID;
        forwardedMessage.dateSent = [NSDate date];
        
        forwardedMessage.deliveredIDs = @[@(currentUser.ID)];
        forwardedMessage.readIDs = @[@(currentUser.ID)];
        forwardedMessage.customParameters[@"save_to_history"] = @"1";
        
        forwardedMessage.markable = YES;
        
        QBUUser *originSenderUser = [self.chatManager.storage userWithID:self.message.senderID];
        if (originSenderUser){
            forwardedMessage.customParameters[KEY_MESSAGE_FORWARDED] = originSenderUser.fullName;
        } else {
            forwardedMessage.customParameters[KEY_MESSAGE_FORWARDED] = currentUser.fullName;
        }
        
        if (self.message.attachments.firstObject) {
            QBChatAttachment *attachment = self.message.attachments.firstObject;
            forwardedMessage.text = @"[Attachment]";
            forwardedMessage.attachments = @[attachment];
        } else {
            forwardedMessage.text = self.message.text;
        }
        [self.chatManager sendMessage:forwardedMessage toDialog:dialog completion:^(NSError * _Nullable error) {;
            if (error) {
                sender.enabled = YES;
            }
            [self handleLeaveDialogsWithIndexPath:indexPath];
        }];
    }
}

- (void)didTapBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapDelete:(UIButton *)sender {
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    if (!self.chatManager.onConnect) {
            [self showAlertWithTitle:@"No Internet Connection" message:@"Make sure your device is connected to the internet" fromViewController:self];
            [SVProgressHUD dismiss];
            return;
    }
    
    QBUUser *currentUser = QBSession.currentSession.currentUser;
    
    NSString *baseAlertMessage = @"Do you really want to leave selected dialog";
    NSString *alertMessage = self.selectedPaths.count == 1 ? [baseAlertMessage stringByAppendingString:@"?"] : [baseAlertMessage stringByAppendingString:@"s?"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"Leave"];
        sender.enabled = NO;
        
        for (NSIndexPath *indexPath in self.selectedPaths) {
            QBChatDialog *dialog = self.dialogs[indexPath.row];
            
            if (dialog.type == QBChatDialogTypePublicGroup) {
                continue;
            } else {
                // group
                dialog.pullOccupantsIDs = @[@(currentUser.ID).stringValue];
                
                NSString *message = [NSString stringWithFormat:@"%@ %@", currentUser.fullName, @"has left"];
                // Notifies occupants that user left the dialog.
                [self.chatManager sendLeaveMessage:message toDialog:dialog completion:^(NSError * _Nullable error) {
                    if (error){
                        Log(@"[%@] sendLeaveMessage error: %@",
                            NSStringFromClass([DialogsSelectionVC class]),
                            error.localizedDescription);
                        [self handleLeaveDialogsWithIndexPath:indexPath];
                        return;
                    }
                    [self.chatManager leaveDialogWithID:dialog.ID completion:^(NSString * _Nullable error) {
                        
                        [self handleLeaveDialogsWithIndexPath:indexPath];
                        
                    }];
                }];
            }
        }
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
    if (self.action == ChatActionDelete) {
        title = DELETE_CHATS;
    }
    NSString *chats = self.selectedPaths.count == 1 ? @"chat" : @"chats";
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

    cell.dialogName.text = chatDialog.name;
    
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
    if (self.action == ChatActionDelete && dialog.type == QBChatDialogTypePublicGroup) {
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

//MARK: - ChatManagerConnectionDelegate
- (void)chatManagerConnect:(ChatManager *)chatManager {
    [self.chatManager updateStorage];
    [SVProgressHUD showSuccessWithStatus:@"Connected!"];

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
