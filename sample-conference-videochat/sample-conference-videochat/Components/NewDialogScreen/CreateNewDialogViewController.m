//
//  CreateNewDialogViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CreateNewDialogViewController.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "EnterChatNameVC.h"
#import "UIViewController+Alert.h"

NSString *const NEW_CHAT = @"New Chat";

@interface CreateNewDialogViewController () <ChatManagerConnectionDelegate>
#pragma mark - Properties

@end

@implementation CreateNewDialogViewController
#pragma mark - Setup
- (void)setupViewWillAppear {
    self.chatManager.connectionDelegate = self;
}

- (void)setupNavigationBar {
    
    self.navBarTitle = NEW_CHAT;
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(createChatButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButtonItem;
    createButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Internal Methods
- (void)setupUsers:(NSArray <QBUUser *> *)users {
    if (!self.users) {
        self.users = NSMutableArray.array;
    }
    NSArray<QBUUser *> *filteredUsers = [NSArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", @(self.currentUser.ID)];
    filteredUsers = [users filteredArrayUsingPredicate:predicate];
    self.users = [filteredUsers mutableCopy];
    if (self.selectedUsers.count) {
        NSMutableSet *usersSet = [NSMutableSet setWithArray:users];
        for (QBUUser *user in self.selectedUsers) {
            if (![usersSet containsObject:user]) {
                [self.users insertObject:user atIndex:0];
                [usersSet addObject:user];
            }
        }
    }
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
}

- (void)addFoundUsers:(NSArray<QBUUser *> *)users {
    [self.foundedUsers addObjectsFromArray:users];
    NSArray<QBUUser *> *filteredUsers = @[];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", @(self.currentUser.ID)];
    filteredUsers = [self.foundedUsers filteredArrayUsingPredicate:predicate];
    self.users = [filteredUsers mutableCopy];
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
}

#pragma mark - Helpers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"enterChatName"]) {
        EnterChatNameVC *chatNameVC = [segue destinationViewController];
        chatNameVC.selectedUsers = self.selectedUsers.allObjects;
    }
}

//MARK: - Actions
- (void)createChatButtonPressed:(UIButton *)sender {
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.isSearch = NO;
    [self performSegueWithIdentifier:@"enterChatName" sender:nil];
}

//MARK: - ChatManagerConnectionDelegate
- (void)chatManagerConnect:(ChatManager *)chatManager {
    [self updateWithConnect];
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
