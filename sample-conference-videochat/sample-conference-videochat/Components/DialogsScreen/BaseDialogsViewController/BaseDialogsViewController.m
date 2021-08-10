//
//  BaseDialogsViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 02.02.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseDialogsViewController.h"

#import "UIViewController+Alert.h"
#import "SVProgressHUD.h"
#import "QBUUser+Chat.h"
#import "NSString+Chat.h"
#import "NSDate+Chat.h"
#import "ChatManager.h"

@interface BaseDialogsViewController ()

@end

@implementation BaseDialogsViewController
@synthesize onConnect;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatManager = [ChatManager instance];

    // configure it if necessary.
    [self setupNavigationBar];
    [self setupNavigationTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadContent];

    // configure it if necessary.
    [self setupDialogs];
}

- (void)setupDialogs {
    // configure it if necessary.
}

- (void)setupNavigationBar {
    // configure it if necessary.
}

- (void)setupNavigationTitle {
    // configure it if necessary.
}

- (void)tableView:(UITableView *)tableView
         configureCell:(DialogCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    // configure it if necessary.
}

- (void)handleLeaveDialog {
    // configure it if necessary.
    [SVProgressHUD dismiss];
}

- (void)reloadContent {
    self.dialogs = [[ChatManager instance].storage dialogsSortByUpdatedAt];
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
    cell.dialogName.text = chatDialog.name;
    NSInteger time = [chatDialog.createdAt timeIntervalSince1970];
    cell.dialogAvatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                          (unsigned long)time]];
    cell.dialogAvatarLabel.text = chatDialog.name.firstLetter;
    
    cell.dialogLastMessage.text = chatDialog.lastMessageText;
    if (chatDialog.lastMessageText.length == 0 && chatDialog.lastMessageID.length != 0) {
        cell.dialogLastMessage.text = @"[Attachment]";
    }
    
    if (chatDialog.lastMessageDate) {
        cell.lastMessageDateLabel.text = chatDialog.lastMessageDate.setupDate;
    } else {
        cell.lastMessageDateLabel.text = chatDialog.updatedAt.setupDate;
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

    // configure it if necessary.
    [self tableView:tableView configureCell:cell forIndexPath:indexPath];
    
    return cell;
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
    if (self.chatManager.isNetworkLost) {
            [self showAlertWithTitle:@"No Internet Connection" message:@"Make sure your device is connected to the internet" fromViewController:self];
            return;
    }
    if (!self.chatManager.onConnect) {
            [self showAlertWithTitle:nil message:@"Chat is not connected" fromViewController:self];;
            return;
    }

    QBChatDialog *dialog = self.dialogs[indexPath.row];
    if (editingStyle != UITableViewCellEditingStyleDelete || dialog.type == QBChatDialogTypePublicGroup) {
        return;
    }
    NSString *deleteMessage = @"Delete";
    if (dialog.type == QBChatDialogTypeGroup) {
        deleteMessage = @"Leave";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                             message:@"Do you really want to leave selected dialog?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:deleteMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"Leaving..."];
        
        QBUUser *currentUser = QBSession.currentSession.currentUser;
        // group
        dialog.pullOccupantsIDs = @[@(currentUser.ID)];
        
        NSString *message = [NSString stringWithFormat:@"%@ %@", currentUser.fullName, @"has left"];
        // Notifies occupants that user left the dialog.
        [self.chatManager sendLeaveMessage:message toDialog:dialog completion:^(NSError * _Nullable error) {
            if (error) {
                Log(@"[%@] sendLeaveMessage error: %@",
                    NSStringFromClass([BaseDialogsViewController class]),
                    error.localizedDescription);
                // configure it if necessary.
                [self handleLeaveDialog];
                return;
            }
            [self.chatManager leaveDialogWithID:dialog.ID completion:^(NSString * _Nullable error) {
                if (error) {
                    Log(@"[%@] leaveDialogWithID error: %@",
                        NSStringFromClass([BaseDialogsViewController class]),
                        error);
                }
                // configure it if necessary.
                [self handleLeaveDialog];
            }];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:leaveAction];
    [self presentViewController:alertController animated:NO completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave";
}

@end
