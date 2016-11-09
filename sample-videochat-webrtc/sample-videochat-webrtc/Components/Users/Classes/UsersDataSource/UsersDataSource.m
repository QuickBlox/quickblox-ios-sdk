//
//  UsersDataSource.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 06/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersDataSource.h"
#import "UserTableViewCell.h"
#import <Quickblox/Quickblox.h>
#import "QBProfile.h"
#import "PlaceholderGenerator.h"

@interface UsersDataSource() {
    
    NSMutableSet <QBUUser *> *_usersSet;
    NSMutableArray <QBUUser *> *_selectedUsers;
    QBUUser *_currentUser;
}

@end

@implementation UsersDataSource

- (instancetype)initWithCurrentUser:(QBUUser *)currentUser {
    
    self = [super init];
    if (self) {
        
        _currentUser = currentUser;
        _usersSet = [NSMutableSet set];
        _selectedUsers = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Public methods

- (BOOL)setUsers:(NSArray *)users {
    
    NSSet *usersSet = [NSSet setWithArray:users];
    
    for (QBUUser *user in users) {
        user.fullName = user.fullName ?: [NSString stringWithFormat:@"User id: %tu (no full name)", user.ID];
    }
    
    if (![_usersSet isEqualToSet:usersSet]) {
        
        [_usersSet removeAllObjects];
        [_usersSet unionSet:usersSet];
        
        for (QBUUser *user in self.selectedUsers) {
            
            if (![_usersSet containsObject:user]) {
                [_selectedUsers removeObject:user];
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (NSArray<QBUUser *> *)selectedUsers {
    
    return [_selectedUsers copy];
}

- (void)selectUserAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    
    if ([_selectedUsers containsObject:user]) {
        [_selectedUsers removeObject:user];
    }
    else {
        [_selectedUsers addObject:user];
    }
}

- (QBUUser *)userWithID:(NSUInteger)ID {
    
    for (QBUUser *user in _usersSet) {
        
        if (user.ID == ID) {
            return user;
        }
    }
    
    return nil;
}

- (NSArray <NSNumber *> *)idsForUsers:(NSArray <QBUUser *>*)users {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [result addObject:@(user.ID)];
    }
    
    return result;
}

- (void)removeAllUsers {
    
    [_usersSet removeAllObjects];
}

- (NSArray <QBUUser *> *)usersSortedByFullName {
    
    return [self sortUsersBySEL:@selector(fullName)];
}

- (NSArray <QBUUser *> *)usersSortedByLastSeen {
    
    return [self sortUsersBySEL:@selector(createdAt)];
}

- (NSArray <QBUUser *> *)sortUsersBySEL:(SEL)selector {
    
    // Create sort Descriptor
    NSSortDescriptor *usersSortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(selector)
                                ascending:NO];
    
    NSArray *sortedUsers = [[self unsortedUsersWithoutMe] sortedArrayUsingDescriptors:@[usersSortDescriptor]];
    
    return sortedUsers;
}

- (NSArray <QBUUser *>*)unsortedUsersWithoutMe {
    
    NSMutableArray *unsorterUsers = [_usersSet.allObjects mutableCopy];
    [unsorterUsers removeObject:_currentUser];
    
    return [unsorterUsers copy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.usersSortedByLastSeen.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    BOOL selected = [_selectedUsers containsObject:user];
    UIImage *userImage = [PlaceholderGenerator placeholderWithSize:CGSizeMake(32, 32)  title:user.fullName];
    
    [cell setFullName:user.fullName];
    [cell setCheck:selected];
    [cell setUserImage:userImage];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = [NSString stringWithFormat:@"Select users for call (%tu)", _selectedUsers.count];
    
    return NSLocalizedString(str, nil);
}

@end
