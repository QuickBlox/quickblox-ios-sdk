//
//  UsersInfoTableViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersInfoTableViewController.h"
#import "AddOccupantsController.h"
#import "UserTableViewCell.h"
#import "ChatManager.h"
#import "Profile.h"
#import "QBUUser+Chat.h"
#import "UIColor+Chat.h"

@interface UsersInfoTableViewController () <ChatManagerDelegate>
@property (nonatomic, strong) NSArray<QBUUser *> *users;
@property (nonatomic, strong) ChatManager *chatManager;
@end

@implementation UsersInfoTableViewController

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.chatManager = [ChatManager instance];
    self.chatManager.delegate = self;
    
    QBChatDialog *dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    if (dialog.occupantIDs.count >= self.chatManager.storage.users.count) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == YES) {
        self.navigationItem.title = currentUser.fullName;
    }
    [self setupUsers:self.dialogID];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add occupants"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didTapAddUsers:)];
    
}

#pragma mark - Actions
- (void)didTapAddUsers:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS", nil) sender:nil];
}

#pragma mark - Internal Methods
- (void)updateUsers {
    QBChatDialog *dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    if (dialog.occupantIDs.count >= self.chatManager.storage.users.count) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if (dialog.occupantIDs.count > 0) {
        [self setupUsers:self.dialogID];
    }
}

- (void)setupUsers:(NSString *)dialogID {
    self.users = [self.chatManager.storage usersWithDialogID:self.dialogID];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

#pragma mark - Overrides
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS", nil)]) {
        AddOccupantsController *addOccupantsVC = segue.destinationViewController;
        addOccupantsVC.dialogID = self.dialogID;
    }
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSLocalizedString(@"SA_STR_CELL_USER", nil)];
    QBUUser *user = self.users[indexPath.row];
    UIColor *color = [UIColor colorWithIndex:indexPath.row];
    cell.colorMarker.bgColor = color;
    cell.userDescriptionLabel.text = user.name;
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
    [self updateUsers];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil)];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if ([chatDialog.ID isEqualToString: self.dialogID]) {
        [self updateUsers];
    }
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

@end
