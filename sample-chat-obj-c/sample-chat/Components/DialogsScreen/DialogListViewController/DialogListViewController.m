//
//  BaseDialogsViewController.m
//  sample-chat
//
//  Created by Injoit on 02.02.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "DialogListViewController.h"
#import "Profile.h"
#import "UIViewController+Alert.h"
#import "QBUUser+Chat.h"
#import "NSString+Chat.h"
#import "NSDate+Chat.h"

@interface DialogListViewController ()

@end

@implementation DialogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatManager = [ChatManager instance];
    self.progressView = [[NSBundle mainBundle] loadNibNamed:@"ProgressView"
                                                      owner:nil
                                                    options:nil].firstObject;
    // Can be overridden in a child class.
    [self setupViews];
    [self setupNavigationTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Can be overridden in a child class.
    [self setupDialogs];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.progressView stop];
}

- (void)setupDialogs {
    // Can be overridden in a child class.
}

- (void)setupViews {
    // Can be overridden in a child class.
}

- (void)setupNavigationTitle {
    // Can be overridden in a child class.
}

- (void)configureCell:(DialogCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    // Can be overridden in a child class.
}

- (void)handleLeaveDialog {
    // Can be overridden in a child class.
}

- (void)reloadContent {
    [self.refreshControl endRefreshing];
    self.dialogs = [self.chatManager.storage dialogsSortByUpdatedAt];
    [self.tableView reloadData];
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
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (chatDialog.type == QBChatDialogTypePrivate) {
        QBUUser *recipient = [self.chatManager.storage userWithID: (NSUInteger)chatDialog.recipientID];
        cell.dialogName.text = recipient ? recipient.name : @(chatDialog.recipientID).stringValue;
    } else {
        cell.dialogName.text = chatDialog.name;
    }
    NSInteger time = [chatDialog.createdAt timeIntervalSince1970];
    cell.dialogAvatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                          (unsigned long)time]];
    cell.dialogAvatarLabel.text = chatDialog.name.firstLetter;
    cell.dialogLastMessage.text = chatDialog.lastMessageText;
    cell.lastMessageDateLabel.text = chatDialog.lastMessageDate ? chatDialog.lastMessageDate.setupDate : chatDialog.updatedAt.setupDate;

    if (chatDialog.unreadMessagesCount > 0) {
        cell.unreadMessageCounterLabel.text = chatDialog.unreadMessagesCount > 99 ? @"99+" :
        [NSString stringWithFormat:@"%@", @(chatDialog.unreadMessagesCount)];
        cell.unreadMessageCounterHolder.hidden = NO;
    } else {
        cell.unreadMessageCounterLabel.text = nil;
        cell.unreadMessageCounterHolder.hidden = YES;
    }

    // Can be overridden in a child class.
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    if (chatDialog.type == QBChatDialogTypePublicGroup) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (editingStyle != UITableViewCellEditingStyleDelete || dialog.type == QBChatDialogTypePublicGroup) {
        return;
    }
    NSString *infoMessage = dialog.type == QBChatDialogTypeGroup ? @"Leave" : @"Delete";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                             message:@"Do you really want to leave selected dialog?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:infoMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.progressView start];
        __weak __typeof(self)weakSelf = self;
        [self.chatManager leaveDialogWithID:dialog.ID completion:^(NSString * _Nullable error) {
            [self.progressView stop];
            if (error) {
                [weakSelf showAlertWithTitle:nil message:error fromViewController:weakSelf handler:nil];
            } else {
                [weakSelf handleLeaveDialog];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:leaveAction];
    [self presentViewController:alertController animated:NO completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (dialog.type == QBChatDialogTypePrivate) {
        return @"Delete";
    }
    return @"Leave";
}

@end
