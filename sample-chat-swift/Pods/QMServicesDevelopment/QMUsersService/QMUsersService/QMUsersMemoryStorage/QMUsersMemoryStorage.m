//
//  QMUsersMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 26.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMUsersMemoryStorage.h"

const struct QMUsersSearchKeyStruct QMUsersSearchKey = {
    .foundObjects = @"kFoundObjects",
    .notFoundSearchValues = @"notFoundSearchValues"
};

@interface QMUsersMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *users;

@end

@implementation QMUsersMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.users = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%tu", user.ID];
    self.users[key] = user;
}

- (void)addUsers:(NSArray *)users {
    
    [users enumerateObjectsUsingBlock:^(QBUUser *user, NSUInteger idx, BOOL *stop) {
        
        [self addUser:user];
    }];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
    NSString *stingID = [NSString stringWithFormat:@"%tu", userID];
    QBUUser *user = self.users[stingID];
    
    return user;
}

- (NSArray *)usersWithIDs:(NSArray *)ids {
    
    NSMutableArray *allFriends = [NSMutableArray array];
    
    for (NSNumber * friendID in ids) {
        
        QBUUser *user = [self userWithID:friendID.integerValue];
        
        if (user) {
            
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

- (NSArray *)idsWithUsers:(NSArray *)users {

    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return [ids allObjects];
}

- (NSArray *)unsortedUsers {
    
    NSArray *allUsers = self.users.allValues;
    return allUsers;
}

- (NSArray *)usersSortedByKey:(NSString *)key ascending:(BOOL)ascending {
    
    NSArray *allUsers = self.users.allValues;
    
    NSSortDescriptor *sorter =
    [[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *sortedUsers = [allUsers sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)contactsSortedByKey:(NSString *)key ascending:(BOOL)ascending {
    
    NSArray *conatctsIDs = [self.delegate contactsIDS];
    NSArray *contacts = [self usersWithIDs:conatctsIDs];
    
    NSSortDescriptor *sorter =
    [[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:@selector(localizedCaseInsensitiveCompare:)];

    NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedContacts;
}

#pragma mark - Utils

- (NSArray *)usersWithIDs:(NSArray *)IDs withoutID:(NSUInteger)ID {
    
    NSMutableArray *withoutMeIDs = IDs.mutableCopy;
    [withoutMeIDs removeObject:@(ID)];
    
    NSArray *result = [self usersWithIDs:withoutMeIDs];
    return result;
}

- (NSString *)joinedNamesbyUsers:(NSArray *)users {
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [components addObject:user.fullName];
    }
    
    NSString *result = [components componentsJoinedByString:@", "];
    return result;
    
}
#pragma mark - QMMemoryStorageProtocol

- (void)free {
    
    [self.users removeAllObjects];
}

#pragma mark - Fetch

- (NSArray *)usersForKeypath:(NSString *)keypath withValues:(NSArray *)values
{
    return [self.users.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(QBUUser*  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [values containsObject:[evaluatedObject valueForKeyPath:keypath]];
    }]];
}

- (NSArray<QBUUser *> *)usersWithLogins:(NSArray<NSString *> *)logins
{
    return [self usersForKeypath:@keypath(QBUUser.new, login) withValues:logins];
}

- (NSArray<QBUUser *> *)usersWithEmails:(NSArray<NSString *> *)emails
{
    return [self usersForKeypath:@keypath(QBUUser.new, email) withValues:emails];
}

- (NSArray<QBUUser *> *)usersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs
{
    return [self usersForKeypath:@keypath(QBUUser.new, facebookID) withValues:facebookIDs];
}

#pragma mark - Filter

- (NSDictionary *)valuesForKeypath:(NSString *)keypath byExcludingValues:(NSArray *)values
{
    NSParameterAssert(values);    
    NSMutableArray* mutableValues = [values mutableCopy];
    
    NSArray* foundUsers = [self.users.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(QBUUser*  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        BOOL contains = [values containsObject:[evaluatedObject valueForKeyPath:keypath]];
        if (contains) {
            [mutableValues removeObject:[evaluatedObject valueForKeyPath:keypath]];
        }
        return contains;
    }]];
    
    return @{QMUsersSearchKey.foundObjects : foundUsers, QMUsersSearchKey.notFoundSearchValues : [mutableValues copy]};
}

- (NSDictionary *)usersByExcludingUsersIDs:(NSArray<NSNumber *> *)ids
{
    return [self valuesForKeypath:@keypath(QBUUser.new, ID) byExcludingValues:ids];
}

- (NSDictionary *)usersByExcludingLogins:(NSArray<NSString *> *)logins
{
    return [self valuesForKeypath:@keypath(QBUUser.new, login) byExcludingValues:logins];
}

- (NSDictionary *)usersByExcludingEmails:(NSArray<NSString *> *)emails
{
    return [self valuesForKeypath:@keypath(QBUUser.new, email) byExcludingValues:emails];
}

- (NSDictionary *)usersByExcludingFacebookIDs:(NSArray<NSString *> *)facebookIDs
{
    return [self valuesForKeypath:@keypath(QBUUser.new, facebookID) byExcludingValues:facebookIDs];
}

@end
