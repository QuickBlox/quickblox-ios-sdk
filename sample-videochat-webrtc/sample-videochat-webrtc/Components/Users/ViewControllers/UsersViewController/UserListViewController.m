//
//  UserListViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 30.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserListViewController.h"
#import "UserTableViewCell.h"
#import "Log.h"
#import "QBUUser+Videochat.h"
#import "UIView+Videochat.h"
#import "UIViewController+Alert.h"

@interface UserListViewController ()
@property (nonatomic, assign) Boolean isProcessing;
@end

@implementation UserListViewController
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nibUserCell = [UINib nibWithNibName:kUserCellIdentifier bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:kUserCellIdentifier];
    self.tableView.allowsMultipleSelection = YES;
    self.userList = [[UserList alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchUsers];
}

//MARK - Setup
- (void)fetchUsers {
    if (self.isProcessing) {
        return;
    }
    self.isProcessing = TRUE;
    [self.refreshControl beginRefreshing];
    __weak __typeof(self)weakSelf = self;
    [self.userList fetchWithPage:1 completion:^(NSArray<QBUUser *> * _Nonnull users, NSError * _Nonnull error) {
        if (users && weakSelf.onFetchedUsers) {
            weakSelf.onFetchedUsers(users);
        }
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.tableView reloadData];
        weakSelf.isProcessing = NO;
    }];
}

- (void)fetchNext {
    __weak __typeof(self)weakSelf = self;
    [self.userList fetchNextWithCompletion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (users && strongSelf.onFetchedUsers) {
            strongSelf.onFetchedUsers(users);
        }
        [strongSelf.tableView reloadData];
    }];
}

//MARK: - Actions
- (IBAction)refreshUsers:(UIRefreshControl *)sender {
    [self fetchUsers];
}

//MARK: - Public Methods
- (void)setupSelectedUsers:(NSArray<QBUUser *> *)users {
    [self.userList appendUsers:users];
    for (QBUUser *user in users) {
        [self.userList.selected addObject:@(user.ID)];
    }
}

- (void)removeSelectedUsers {
    for (NSIndexPath *indexPathForSelectedRow in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow animated:NO];
    }
    [self.userList.selected removeAllObjects];
}

- (void)removeSelectedUser:(QBUUser *)user {
    NSUInteger index = [self.userList.fetched indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.userList.selected removeObject:@(user.ID)];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.fetched.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kUserCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    QBUUser *user = self.userList.fetched[indexPath.row];
    [cell setupUserID:user.ID];
    [cell setupUserName:user.name];
    cell.tag = indexPath.row;
    
    NSUInteger lastItemNumber = self.userList.fetched.count - 1;
    if (indexPath.row == lastItemNumber && self.userList.isLoadAll == NO) {
        [self fetchNext];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.userList.selected.count > 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    QBUUser *user = self.userList.fetched[indexPath.row];
    [self.userList.selected addObject:@(user.ID)];
    if (self.onSelectUser) {
        self.onSelectUser(user, YES);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.userList.fetched[indexPath.row];
    if (![self.userList.selected containsObject:@(user.ID)]) {
        return;
    }
    [self.userList.selected removeObject:@(user.ID)];
    if (self.onSelectUser) {
        self.onSelectUser(user, NO);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QBUUser *user = self.userList.fetched[indexPath.row];
    if ([self.userList.selected containsObject:@(user.ID)]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
