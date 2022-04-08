//
//  DialogsSelectionVC.m
//  sample-chat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "DialogsSelectionViewController.h"
#import "QBUUser+Chat.h"
#import "TitleView.h"
#import "UIView+Chat.h"
#import "UIViewController+Alert.h"

NSString *const MESSAGE_FORWARDED = @"Message forwarded";
NSString *const DELETE_CHATS = @"Delete Chats";
NSString *const KEY_MESSAGE_FORWARDED = @"origin_sender_name";

@interface DialogsSelectionViewController()
//MARK: - Properties
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *selectedPaths;
@end

@implementation DialogsSelectionViewController

- (void)setupDialogs {
    [self reloadContent];
    self.selectedPaths = [NSMutableSet set];
}

- (void)setupViews {
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

- (void)setupNavigationTitle {
    NSString *title = self.action == ChatActionDelete ? DELETE_CHATS : MESSAGE_FORWARDED;
    NSString *chats = self.selectedPaths.count > 1 ? @"chats" : @"chat";
    NSString *numberChats = [NSString stringWithFormat:@"%@ %@ selected", @(self.selectedPaths.count), chats];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberChats];
}

#pragma mark - Actions
- (void)didTapSend:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    if (!self.message) {
        return;
    }
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    sender.enabled = NO;
    [self.progressView start];
    dispatch_group_t sendGroup = dispatch_group_create();
    for (NSIndexPath *indexPath in self.selectedPaths) {
        QBChatDialog *dialog = self.dialogs[indexPath.row];
        if (!dialog) {
            continue;
        }
        dispatch_group_enter(sendGroup);
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
        [self.chatManager sendMessage:forwardedMessage toDialog:dialog completion:^(NSError * _Nullable error) {
            dispatch_group_leave(sendGroup);
            if (error) {
                Log(@"[%@] Send Forwarded Message error: %@",  NSStringFromClass([DialogsSelectionViewController class]), error.localizedDescription);
            }
            if (!error) {
                [self.selectedPaths removeObject:indexPath];
            }
        }];
    }
    dispatch_group_notify(sendGroup, dispatch_get_main_queue(), ^{
        [self handleLeaveDialog];
    });
}

- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didTapDelete:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    NSString *baseAlertMessage = @"Do you really want to leave selected dialog";
    NSString *alertMessage = self.selectedPaths.count == 1 ? [baseAlertMessage stringByAppendingString:@"?"] : [baseAlertMessage stringByAppendingString:@"s?"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"Leave"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        sender.enabled = NO;
        [self.progressView start];
        dispatch_group_t deleteGroup = dispatch_group_create();
        for (NSIndexPath *indexPath in self.selectedPaths) {
            QBChatDialog *dialog = self.dialogs[indexPath.row];
            if (dialog.type == QBChatDialogTypePublicGroup) {
                continue;
            }
            dispatch_group_enter(deleteGroup);
            [self.chatManager leaveDialogWithID:dialog.ID completion:^(NSString * _Nullable error) {
                dispatch_group_leave(deleteGroup);
                if (error) {
                    Log(@"[%@] Leave Dialog error: %@",  NSStringFromClass([DialogsSelectionViewController class]), error);
                }
                if (!error) {
                    [self.selectedPaths removeObject:indexPath];
                }
            }];
        }
        dispatch_group_notify(deleteGroup, dispatch_get_main_queue(), ^{
            [self handleLeaveDialog];
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

- (void)handleLeaveDialog {
    [self.progressView stop];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)configureCell:(DialogCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    self.tableView.allowsMultipleSelection = YES;
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
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dialogs.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (self.action != ChatActionDelete || chatDialog.type == QBChatDialogTypePublicGroup) {
        return NO;
    }
    return YES;
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
            [self showAlertWithTitle:title message:nil fromViewController:self handler:nil];
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

@end
