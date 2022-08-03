//
//  UserListViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 30.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "UserList.h"

NS_ASSUME_NONNULL_BEGIN

@class QBUUser;

typedef void(^SelectUserCompletion)(QBUUser *user, BOOL isSelect);
typedef void(^FetchedUsersCompletion)(NSArray<QBUUser *>* users);


@interface UserListViewController : UITableViewController

@property (nonatomic, readwrite, copy, nullable) SelectUserCompletion onSelectUser;
@property (nonatomic, readwrite, copy, nullable) FetchedUsersCompletion onFetchedUsers;

@property(nonatomic, strong) UserList *userList;
- (void)fetchUsers;
- (void)fetchNext;
- (void)removeSelectedUsers;
- (void)removeSelectedUser:(QBUUser *)user;
- (void)setupSelectedUsers:(NSArray<QBUUser *> *)users;

@end

NS_ASSUME_NONNULL_END
