//
//  SearchUsersViewController.m
//  sample-chat
//
//  Created by Injoit on 30.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "UITableView+Chat.h"
#import "UserList+Search.h"

NSString *const NO_USERS_NAME = @"No user with that name";

@implementation SearchUsersViewController
- (instancetype)initWithNonDisplayedUsers:(NSArray<NSNumber *> *)nonDisplayedUsers
                     searchText:(NSString *)searchText {
    if (self = [super initWithNonDisplayedUsers:nonDisplayedUsers]) {
        self.searchText = searchText;
    }
    return self;
}

//MARK - Setup
- (void)setupSelectedUsers:(NSArray<QBUUser *> *)users {
    for (QBUUser *user in users) {
        [self.userList.selected addObject:@(user.ID)];
    }
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText;
    if (searchText.length > 2) {
        [self searchUsersWithName:searchText];
    }
}

//MARK: - Public Methods
- (void)fetchUsers {
    [self searchUsersWithName:self.searchText];
}

- (void)fetchNext {
    __weak __typeof(self)weakSelf = self;
    [self.userList searchNextWithName:self.searchText completion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (users && strongSelf.onFetchedUsers) {
            strongSelf.onFetchedUsers(users);
        }
        [strongSelf.tableView reloadData];
    }];
}

//MARK: - Private Methods
- (void)searchUsersWithName:(NSString *)name {
    [self.refreshControl beginRefreshing];
    __weak __typeof(self)weakSelf = self;
    [self.userList searchWithName:name page:1 completion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (users.count == 0 && error.code == QBResponseStatusCodeNotFound) {
            [strongSelf.userList.fetched removeAllObjects];
            [strongSelf.tableView setupEmptyViewWithAlert:NO_USERS_NAME];
        } else if (users.count > 0 && strongSelf.onFetchedUsers) {
            strongSelf.onFetchedUsers(users);
            [strongSelf.tableView removeEmptyView];
        }
        [strongSelf.refreshControl endRefreshing];
        [strongSelf.tableView reloadData];
    }];
}

@end
