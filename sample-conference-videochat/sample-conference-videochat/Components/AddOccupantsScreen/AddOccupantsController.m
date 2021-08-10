//
//  AddOccupantsController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AddOccupantsController.h"
#import "ChatViewController.h"

NSString *const ADD_MEMBERS = @"Add Members";
NSString *const NO_USERS_FOUND = @"No user with that name";
const NSUInteger kPerPageUsers = 100;

@interface AddOccupantsController () <ChatManagerDelegate, UISearchBarDelegate>
//MARK: - Properties
@property (nonatomic, strong) QBChatDialog *dialog;
@end

@implementation AddOccupantsController
- (void)setupNavigationBar {
    self.navBarTitle = ADD_MEMBERS;
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addOccupantsButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButtonItem;
    createButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)setupViewWillAppear {
    self.chatManager.delegate = self;
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
}

- (void)addFoundUsers:(NSArray<QBUUser *> *)users {
    NSMutableArray<QBUUser *> *filteredUsers = [NSMutableArray array];
    for (QBUUser *user in users) {
        if (user.ID == self.currentUser.ID) {
            continue;
        }
        if (![self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [filteredUsers addObject:user];
        }
    }
    NSMutableSet<QBUUser *> *removedUsers = [NSMutableSet set];
    for (QBUUser *user in self.selectedUsers) {
        if ([self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [removedUsers addObject:user];
        }
    }
    [self.selectedUsers minusSet:removedUsers];
    
    [self.foundedUsers addObjectsFromArray:filteredUsers.copy];
    
    self.users = self.foundedUsers;
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
}

- (void)setupUsers:(NSArray <QBUUser *> *)users {
    if (!self.users) {
        self.users = NSMutableArray.array;
    }
    [self.users removeAllObjects];
    
    NSArray *occupantIDs = self.dialog.occupantIDs;
    
    for (QBUUser *user in users) {
        if (user.ID == self.currentUser.ID) {
            continue;
        }
        if (![occupantIDs containsObject:@(user.ID)]) {
            [self.users addObject:user];
        }
    }
    NSMutableSet<QBUUser *> *removedUsers = [NSMutableSet set];
    for (QBUUser *user in self.selectedUsers) {
        if ([occupantIDs containsObject:@(user.ID)]) {
            [removedUsers addObject:user];
        }
    }
    [self.selectedUsers minusSet:removedUsers];
    
    if (self.selectedUsers.count) {
        NSMutableSet *usersSet = [NSMutableSet setWithArray:self.users.copy];
        for (QBUUser *user in self.selectedUsers) {
            if (![usersSet containsObject:user]) {
                [self.users insertObject:user atIndex:0];
                [usersSet addObject:user];
            }
        }
    }
    
    [self checkCreateChatButtonState];
    [self.tableView reloadData];
}

- (void)addOccupantsButtonPressed:(UIButton *)sender {
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.isSearch = NO;
    sender.enabled = NO;
    NSArray *selectedUsers = self.selectedUsers.allObjects;
    [self.chatManager.storage updateUsers:selectedUsers];
    [SVProgressHUD show];
    NSMutableArray *newUsersIDs = [NSMutableArray array];
    
    for (QBUUser *user in selectedUsers) {
        [newUsersIDs addObject:@(user.ID)];
    }
    NSArray *usersIDs = [newUsersIDs copy];
    // Updates dialog with new occupants.
    __weak __typeof(self)weakSelf = self;
    [self.chatManager joinOccupantsWithIDs:usersIDs
                                  toDialog:self.dialog
                                completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (!updatedDialog || response.error) {
            sender.enabled = YES;
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
        NSArray *controllers = strongSelf.navigationController.viewControllers;
        NSMutableArray *newStack = [NSMutableArray array];
        
        //change stack by replacing view controllers after ChatVC with ChatVC
        for (UIViewController *controller in controllers) {
            if ([controller isKindOfClass:[ChatViewController class]]) {
                ChatViewController *chatController = (ChatViewController *)controller;
                chatController.dialog = updatedDialog;
                [newStack addObject:chatController];
                [strongSelf.navigationController setViewControllers:[newStack copy]];
                [chatController sendAddOccupantsMessages:usersIDs action:DialogActionTypeAdd];
                return;
            }
        }
    }];
}

#pragma mark Chat Manager Delegate
- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:@"Loading users"];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if ([chatDialog.ID isEqualToString: self.dialogID]) {
        self.dialog = chatDialog;
        [self setupUsers:self.users.copy];
    }
}

@end
