//
//  UserListViewController.m
//  sample-chat
//
//  Created by Injoit on 30.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserListViewController.h"
#import "Log.h"
#import "QBUUser+Chat.h"
#import "UIView+Chat.h"
#import "UIViewController+Alert.h"

@interface UserListViewController () <QBChatDelegate>
@end

@implementation UserListViewController

//MARK: - Life Cycle
- (instancetype)initWithNonDisplayedUsers:(NSArray<NSNumber *> *)nonDisplayedUsers {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.userList = [[UserList alloc] initWithNonDisplayedUsers:nonDisplayedUsers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nibUserCell = [UINib nibWithNibName:kUserCellIdentifier bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:kUserCellIdentifier];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.98f alpha:1.0f];
    self.profile = [[Profile alloc] init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUsers) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self fetchUsers];
}

//MARK - Setup
- (void)fetchUsers {
    [self.refreshControl beginRefreshing];
    __weak __typeof(self)weakSelf = self;
    [self.userList fetchWithPage:1 completion:^(NSArray<QBUUser *> * _Nonnull users, NSError * _Nonnull error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (users && strongSelf.onFetchedUsers) {
            strongSelf.onFetchedUsers(users);
        }
        [strongSelf.refreshControl endRefreshing];
        [strongSelf.tableView reloadData];
    }];
}

- (void)fetchNext {
    [self.refreshControl beginRefreshing];
    __weak __typeof(self)weakSelf = self;
    [self.userList fetchNextWithCompletion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (users && strongSelf.onFetchedUsers) {
            strongSelf.onFetchedUsers(users);
        }
        [strongSelf.refreshControl endRefreshing];
        [strongSelf.tableView reloadData];
    }];
}

//MARK: - Actions
- (void)refreshUsers {
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

- (void)tableView:(UITableView *)tableView
         configureCell:(UserTableViewCell *)cell
     forIndexPath:(NSIndexPath *)indexPath {
    // Can be overridden in a child class.
    NSUInteger lastItemNumber = self.userList.fetched.count - 1;
    if (!self.action && indexPath.row == lastItemNumber && self.userList.isLoadAll == NO) {
        [self fetchNext];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.fetched.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
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
    if (self.profile.ID == user.ID) {
        [cell setupUserName:[NSString stringWithFormat:@"%@ %@", user.name,  @"(You)"]];
    }
    cell.tag = indexPath.row;
    
    [self tableView:tableView configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.userList.fetched[indexPath.row];
    [self.userList.selected addObject:@(user.ID)];
    if (self.onSelectUser) {
        self.onSelectUser(user, YES);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.userList.fetched[indexPath.row];
    if (![self.userList.selected containsObject:@(user.ID)]) {return;}
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

#pragma mark - QBChatDelegate
- (void)chatDidConnect {
    [self fetchUsers];
}

- (void)chatDidReconnect {
    [self fetchUsers];;
}

@end
