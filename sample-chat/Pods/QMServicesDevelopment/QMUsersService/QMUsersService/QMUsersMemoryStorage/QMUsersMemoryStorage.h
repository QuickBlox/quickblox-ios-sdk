//
//  QMUsersMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 26.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

struct QMUsersSearchKeyStruct {
    __unsafe_unretained NSString * _Nullable foundObjects;
    __unsafe_unretained NSString * _Nullable notFoundSearchValues;
};

extern const struct QMUsersSearchKeyStruct QMUsersSearchKey;

@protocol QMUsersMemoryStorageDelegate <NSObject>

- (nullable NSArray QB_GENERIC(NSNumber *) *)contactsIDS;

@end

@interface QMUsersMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 *  Delegate for getting UsersMemoryStorage user ids.
 */
@property (weak, nonatomic, nullable) id <QMUsersMemoryStorageDelegate> delegate;

/**
 *  Add user to memory storage.
 *
 *  @param user QBUUser instance of user to add
 */
- (void)addUser:(QBUUser *)user;

/**
 *  Add users to memory storage.
 *
 *  @param users array of QBUUser instances of users to add
 */
- (void)addUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

#pragma mark - Sorting

/**
 *  Get all users from memory storage without sorting.
 *
 *  @return Array of QBUUsers instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)unsortedUsers;

/**
 *  Get all users in memory storage sorted by key.
 *
 *  @param key          sorted key
 *  @param ascending    ascending value
 *
 *  @return Array of QBUUsers instances as users
 */
- (NSArray QB_GENERIC(QBUUser *)*)usersSortedByKey:(NSString *)key ascending:(BOOL)ascending;

#pragma mark Contacts

/**
 *  Get all contacts in memory storage sorted by key.
 *
 *  @param key          sorted key
 *  @param ascending    ascending value
 *
 *  @return Array of QBUUsers instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)contactsSortedByKey:(NSString *)key ascending:(BOOL)ascending;

#pragma mark Utils

/**
 *  Get users with ids without some id.
 *
 *  @param IDs  array of users IDs
 *  @param ID   exclude ID
 *
 *  @return Array of QBUUsers instances as users
 */
- (NSArray *)usersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)IDs withoutID:(NSUInteger)ID;

/**
 *  Get string created from users full names, separated by ",".
 *
 *  @param users array of QBUUser instances
 *
 *  @return joined names string, separated by ","
 */
- (NSString *)joinedNamesbyUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

#pragma mark - Fetch

/**
 *  Get user with user id.
 *
 *  @param userID user ID
 *
 *  @return QBUUser instance of user
 */
- (nullable QBUUser *)userWithID:(NSUInteger)userID;

/**
 *  Get user with external user id.
 *
 *  @param externalUserID external user ID
 *
 *  @return QBUUser instance of user
 */
- (nullable QBUUser *)userWithExternalID:(NSUInteger)externalUserID;

/**
 *  Get users with external user ids.
 *
 *  @param externalUserIDs  external users IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithExternalIDs:(NSArray QB_GENERIC(NSNumber *) *)externalUserIDs;

/**
 *  Get users with user ids.
 *
 *  @param ids users IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)ids;

/**
 *  Get users with user logins.
 *
 *  @param logins   array of user logins
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Get users with user emails.
 *
 *  @param emails   array of user emails
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails;

/**
 *  Get users with user facebook ids.
 *
 *  @param facebookIDs  array of user facebook IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs;

/**
 *  Get users with user twitter ids.
 *
 *  @param twitterIDs  array of user twitter IDs
 *
 *  @return Array of QBUUser instances as users
 */
- (NSArray QB_GENERIC(QBUUser *) *)usersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs;

#pragma mark - Search & Exclude

/**
 *  Search for users excluding users with users ids.
 *
 *  @param ids  users ids to exclude
 *
 *  @return dictionary of found and not found users
 */
- (NSDictionary *)usersByExcludingUsersIDs:(NSArray QB_GENERIC(NSNumber *) *)ids;

/**
 *  Search for users excluding users with users logins.
 *
 *  @param logins  users logins to exclude
 *
 *  @return dictionary of found and not found users
 */
- (NSDictionary *)usersByExcludingLogins:(NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Search for users excluding users with users logins.
 *
 *  @param emails  users emails to exclude
 *
 *  @return dictionary of found and not found users
 */
- (NSDictionary *)usersByExcludingEmails:(NSArray QB_GENERIC(NSString *) *)emails;

/**
 *  Search for users excluding users with users facebook IDs.
 *
 *  @param facebookIDs  users facebookIDs to exclude
 *
 *  @return dictionary of found and not found users
 */
- (NSDictionary *)usersByExcludingFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs;

/**
 *  Search for users excluding users with users twitter IDs.
 *
 *  @param twitterIDs  users twitterIDs to exclude
 *
 *  @return dictionary of found and not found users
 */
- (NSDictionary *)usersByExcludingTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs;

@end

NS_ASSUME_NONNULL_END
