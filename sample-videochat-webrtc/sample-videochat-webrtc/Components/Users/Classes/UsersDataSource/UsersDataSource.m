//
//  UsersDataSource.m
//  LoginComponent
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersDataSource.h"
#import "UserTableViewCell.h"
#import <Quickblox/Quickblox.h>
#import "Profile.h"
#import "PlaceholderGenerator.h"
#import "User.h"

@interface UsersDataSource()

@property (strong, nonatomic) NSMutableArray <QBUUser *> *_selectedUsers;
@property (strong, nonatomic) NSMutableArray <QBUUser *> *users;

@end

@implementation UsersDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self._selectedUsers = [NSMutableArray array];
        self.users = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public methods

- (void)updateUsers:(NSArray<QBUUser *> *)users {
    for (QBUUser *chatUser in users) {
        [self updateUser:chatUser];
    }
}

- (void)updateUser:(QBUUser *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(user.ID)];
    QBUUser *localUser = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    if (localUser) {
        //Update local User
        localUser.fullName = user.fullName;
        localUser.updatedAt = user.updatedAt;
        return;
    }
    [self.users addObject:user];
}

- (NSArray<QBUUser *> *)selectedUsers {
    
    return [self._selectedUsers copy];
}

- (void)selectUserAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    
    if ([self._selectedUsers containsObject:user]) {
        [self._selectedUsers removeObject:user];
    }
    else {
        [self._selectedUsers addObject:user];
    }
}

- (QBUUser *)userWithID:(NSUInteger)ID {
    
    for (QBUUser *user in self.users) {
        
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
    
    [self.users removeAllObjects];
}

- (NSArray <QBUUser *> *)usersSortedByFullName {
    
    return [self sortUsersBySEL:@selector(fullName)];
}

- (NSArray <QBUUser *> *)usersSortedByLastSeen {
    
    return [self sortUsersBySEL:@selector(updatedAt)];
}

- (NSArray <QBUUser *> *)sortUsersBySEL:(SEL)selector {

    Profile *profile = [[Profile alloc] init];
    User *me = [[User alloc] initWithID:profile.ID fullName:profile.fullName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", me.ID];
    NSArray *unsorterUsers = [self.users filteredArrayUsingPredicate:predicate];
    
    // Create sort Descriptor
    NSSortDescriptor *usersSortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(selector)
                                ascending:NO];
    NSArray *sortedUsers = [unsorterUsers sortedArrayUsingDescriptors:@[usersSortDescriptor]];
    
    return sortedUsers;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.usersSortedByLastSeen.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    QBUUser *user = self.usersSortedByLastSeen[indexPath.row];
    BOOL selected = [self._selectedUsers containsObject:user];
    NSString *name = user.fullName.length > 0 ? user.fullName : user.login;
    UIImage *userImage = [PlaceholderGenerator placeholderWithSize:CGSizeMake(32, 32)  title:name];
    
    [cell setFullName:name];
    [cell setCheck:selected];
    [cell setUserImage:userImage];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = [NSString stringWithFormat:@"Select users for call (%tu)", self._selectedUsers.count];
    
    return NSLocalizedString(str, nil);
}

@end
