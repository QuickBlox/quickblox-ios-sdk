//
//  UsersInfoTableViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersInfoTableViewController.h"
#import "AddOccupantsController.h"

@interface UsersInfoTableViewController () <ChatManagerDelegate>
#pragma mark - Properties
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) UIBarButtonItem *addUsersItem;
@end

@implementation UsersInfoTableViewController

- (void)setupNavigationBar {
    self.addUsersItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_user"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(didTapAddUsers:)];
    self.navigationItem.rightBarButtonItem = self.addUsersItem;
    self.addUsersItem.tintColor = UIColor.whiteColor;
    
    self.addUsersItem.tintColor = UIColor.whiteColor;
    self.addUsersItem.enabled = YES;
}

- (void)isUseSearchBar {
    self.useSearchBar = NO;
}

- (void)setupViewWillAppear {
    self.chatManager.delegate = self;
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    
    __weak __typeof(self)weakSelf = self;
    self.dialog.onJoinOccupant = ^(NSUInteger userID) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (userID == self.currentUser.ID) {
            return;
        }
        [strongSelf chatDidBecomeOnlineUser:@(userID)];
    };
    
    [self setupUsers];
}

- (void)updateWithConnect {
    [self updateUsers];
}

- (void)setupFetchUsers {}

#pragma mark - Setup
- (void)setupNavigationTitle {
    NSString *title = self.dialog.name;
    NSString *numberUsers = [NSString stringWithFormat:@"%@ members", @(self.users.count)];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

- (void)tableView:(UITableView *)tableView
         configureCell:(UserTableViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    if (self.currentUser.ID == user.ID) {
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.name,  @"(You)"];
    } else {
        cell.userNameLabel.text = user.name;
    }

    cell.checkBoxView.hidden = YES;
    cell.checkBoxImageView.hidden = YES;
    cell.userInteractionEnabled = NO;
}

- (void)chatDidBecomeOnlineUser:(NSNumber *)userID {
    
    __weak __typeof(self) weakSelf = self;
    void(^handlerDidBecomeOnlineUser)(QBUUser *onlineUser) = ^(QBUUser *onlineUser) {
        NSMutableArray *arrayOfUsers = [NSMutableArray arrayWithArray:weakSelf.users.copy];
        NSInteger index = [arrayOfUsers indexOfObject:onlineUser];
        [arrayOfUsers removeObject:onlineUser];
        [arrayOfUsers insertObject:onlineUser atIndex:0];
        weakSelf.users = arrayOfUsers.copy;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath * indexPathFirst = [NSIndexPath indexPathForRow:0 inSection:0];
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView insertRowsAtIndexPaths:@[indexPathFirst] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
    };

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    QBUUser *onlineUser = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    
    if (!onlineUser) {
        [self.chatManager loadUserWithID:userID.unsignedIntValue completion:^(QBUUser * _Nullable user) {
            handlerDidBecomeOnlineUser(user);
        }];
    } else {
        handlerDidBecomeOnlineUser(onlineUser);
    }
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddUsers:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"goToAddOpponents" sender:nil];
}

- (void)checkCreateChatButtonState {}

#pragma mark - Internal Methods
- (void)updateUsers {
    QBChatDialog *dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    if (dialog.occupantIDs.count > 0) {
        [self setupUsers];
    }
}

- (void)setupUsers {
    switch (self.action) {
        case ChatActionChatInfo:
            self.users = [[self.chatManager.storage usersWithDialogID:self.dialogID] mutableCopy];
            break;
            
        default:
            break;
    }
    
    [self setupNavigationTitle];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

#pragma mark - Helpers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToAddOpponents"]) {
        AddOccupantsController *addOccupantsVC = segue.destinationViewController;
        addOccupantsVC.dialogID = self.dialogID;
    }
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
    [self setupUsers];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:@"Loading users"];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if (![chatDialog.ID isEqualToString: self.dialogID]) {
        return;
    }
    [self updateUsers];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

@end
