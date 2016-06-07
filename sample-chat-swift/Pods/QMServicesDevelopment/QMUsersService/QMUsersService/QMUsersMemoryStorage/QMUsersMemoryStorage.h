//
//  QMUsersMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 26.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

struct QMUsersSearchKeyStruct {
    __unsafe_unretained NSString* QB_NULLABLE_S foundObjects;
    __unsafe_unretained NSString* QB_NULLABLE_S notFoundSearchValues;
};

extern const struct QMUsersSearchKeyStruct QMUsersSearchKey;


@protocol QMUsersMemoryStorageDelegate <NSObject>

- (QB_NULLABLE NSArray QB_GENERIC(NSNumber *) *)contactsIDS;

@end

@interface QMUsersMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 *  Delegate for getting UsersMemoryStorage user ids.
 */
@property (weak, nonatomic, QB_NULLABLE) id <QMUsersMemoryStorageDelegate> delegate;

/**
 *  Add user to memory storage.
 *
 *  @param user QBUUser instance of user to add
 */
- (void)addUser:(QB_NONNULL QBUUser *)user;

/**
 *  Add users to memory storage.
 *
 *  @param users array of QBUUser instances of users to add
 */
- (void)addUsers:(QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)users;

#pragma mark - Sorting

/**
 *  Get all users from memory storage without sorting.
 *
 *  @return Array of QBUUsers instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)unsortedUsers;

/**
 *  Get all users in memory storage sorted by key.
 *
 *  @param key          sorted key
 *  @param ascending    ascending value
 *
 *  @return Array of QBUUsers instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *)*)usersSortedByKey:(QB_NONNULL NSString *)key ascending:(BOOL)ascending;

#pragma mark Contacts

/**
 *  Get all contacts in memory storage sorted by key.
 *
 *  @param key          sorted key
 *  @param ascending    ascending value
 *
 *  @return Array of QBUUsers instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)contactsSortedByKey:(QB_NONNULL NSString *)key ascending:(BOOL)ascending;

#pragma mark Utils

/**
 *  Get users with ids without some id.
 *
 *  @param IDs  array of users IDs
 *  @param ID   exclude ID
 *
 *  @return Array of QBUUsers instances as users
 */
- (QB_NONNULL NSArray *)usersWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)IDs withoutID:(NSUInteger)ID;

/**
 *  Get string created from users full names, separated by ",".
 *
 *  @param users array of QBUUser instances
 *
 *  @return joined names string, separated by ","
 */
- (QB_NONNULL NSString *)joinedNamesbyUsers:(QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)users;

#pragma mark - Fetch

/**
 *  Get user with user id.
 *
 *  @param userID user ID
 *
 *  @return QBUUser instance of user
 */
- (QB_NULLABLE QBUUser *)userWithID:(NSUInteger)userID;

/**
 *  Get user with external user id.
 *
 *  @param externalUserID external user ID
 *
 *  @return QBUUser instance of user
 */
- (QB_NULLABLE QBUUser *)userWithExternalID:(NSUInteger)externalUserID;

/**
 *  Get users with external user ids.
 *
 *  @param externalUserIDs  external users IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithExternalIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)externalUserIDs;

/**
 *  Get users with user ids.
 *
 *  @param ids users IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)ids;

/**
 *  Get users with user logins.
 *
 *  @param logins   array of user logins
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithLogins:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Get users with user emails.
 *
 *  @param emails   array of user emails
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithEmails:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)emails;

/**
 *  Get users with user facebook ids.
 *
 *  @param facebookIDs  array of user facebook IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithFacebookIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)facebookIDs;

/**
 *  Get users with user twitter ids.
 *
 *  @param twitterIDs  array of user twitter IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)usersWithTwitterIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)twitterIDs;

#pragma mark - Search & Exclude

/**
 *  Search for users excluding users with users ids.
 *
 *  @param ids  users ids to exclude
 *
 *  @return dictionary of found and not found users
 */
- (QB_NONNULL NSDictionary *)usersByExcludingUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)ids;

/**
 *  Search for users excluding users with users logins.
 *
 *  @param logins  users logins to exclude
 *
 *  @return dictionary of found and not found users
 */
- (QB_NONNULL NSDictionary *)usersByExcludingLogins:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Search for users excluding users with users logins.
 *
 *  @param emails  users emails to exclude
 *
 *  @return dictionary of found and not found users
 */
- (QB_NONNULL NSDictionary *)usersByExcludingEmails:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)emails;

/**
 *  Search for users excluding users with users facebook IDs.
 *
 *  @param facebookIDs  users facebookIDs to exclude
 *
 *  @return dictionary of found and not found users
 */
- (QB_NONNULL NSDictionary *)usersByExcludingFacebookIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)facebookIDs;

/**
 *  Search for users excluding users with users twitter IDs.
 *
 *  @param twitterIDs  users twitterIDs to exclude
 *
 *  @return dictionary of found and not found users
 */
- (QB_NONNULL NSDictionary *)usersByExcludingTwitterIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)twitterIDs;

@end
