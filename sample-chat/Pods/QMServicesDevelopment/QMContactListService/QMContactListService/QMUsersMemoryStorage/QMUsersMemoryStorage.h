//
//  QMUsersMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 26.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

@protocol QMUsersMemoryStorageDelegate <NSObject>

- (NSArray *)contactsIDS;

@end

@interface QMUsersMemoryStorage : NSObject <QMMemoryStorageProtocol>

@property (weak, nonatomic) id <QMUsersMemoryStorageDelegate> delegate;

/**
 *  Added user to memory storage
 *
 *  @param user QBUUser item to add
 */
- (void)addUser:(QBUUser *)user;

/**
 *  Added users to memory storage
 *
 *  @param users QBUUser items to add
 */
- (void)addUsers:(NSArray *)users;

/**
 *  Get user by user id
 *
 *  @param userID user ID
 *
 *  @return finded QBUUser
 */
- (QBUUser *)userWithID:(NSUInteger)userID;

/**
 *  Get users by user ids
 *
 *  @param ids users IDs
 *
 *  @return finded array of QBUUser
 */
- (NSArray *)usersWithIDs:(NSArray *)ids;

#pragma mark - Sorting

/**
 *  Get all users in memory storage
 *
 *  @return Array of QBUUsers items
 */
- (NSArray *)unsortedUsers;

/**
 *  Get all users in memory storage sorted by key
 *
 *  @param key sorted key
 *  @param
 *
 *  @return Array of QBUUsers items
 */
- (NSArray *)usersSortedByKey:(NSString *)key ascending:(BOOL)ascending;

#pragma mark Contacts

/**
 *  Get all users in memory storage sorted by key
 *
 *  @param key sorted key
 *  @param ascending value
 *
 *  @return Array of QBUUsers items
 */
- (NSArray *)contactsSortedByKey:(NSString *)key ascending:(BOOL)ascending;

#pragma mark Utils

/**
 *  Get users by ids except some ID
 *
 *  @param IDs array of users IDs
 *  @param ID exclude ID
 *
 *  @return Array of QBUUsers items
 */
- (NSArray *)usersWithIDs:(NSArray *)IDs withoutID:(NSUInteger)ID;

/**
 *  Get string created from users full names, separated by ",".
 *  
 *  @param users array of QBUUser
 *
 *  @return joined names string
 */
- (NSString *)joinedNamesbyUsers:(NSArray *)users;

@end
