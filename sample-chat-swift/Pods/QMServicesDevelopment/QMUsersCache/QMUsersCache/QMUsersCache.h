//
//  QMUsersCache.h
//  QMUsersCache
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import <Quickblox/Quickblox.h>
#import "QMDBStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMUsersCache : QMDBStorage

@property (readonly, class) QMUsersCache *instance;

+ (nullable QMUsersCache *)instance;

//MARK: - Insert/Update/Delete users in cache

/**
 *  Insert/Update user in cache
 *
 *  @param user       QBUUser instance
 */
- (BFTask *)insertOrUpdateUser:(QBUUser *)user;

/**
 *  Insert/Update users in cache
 *
 *  @param users Array of QBUUser instances
 */
- (BFTask *)insertOrUpdateUsers:(NSArray<QBUUser *> *)users;

/**
 *  Delete user from cahce
 *
 *  @param user QBUUser instance
 */
- (BFTask *)deleteUser:(QBUUser *)user;

/**
 *  Delete all users
 */
- (BFTask *)deleteAllUsers;

//MARK: - Fetch users

- (NSArray <QBUUser*> *)allUsers;

/**
 *  Fetch user with predicate
 *
 *  @param predicate  Predicate to evaluate objects against
 */
- (BFTask<QBUUser *> *)userWithPredicate:(NSPredicate *) predicate;

/**
 *  Fetch users with sort attribute, sorted ascending
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 */
- (BFTask <NSArray<QBUUser *> *> *)usersSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;

/**
 *  Fetch users with predicate, sort attribute, sorted ascending
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 */
- (BFTask <NSArray<QBUUser *> *> *)usersWithPredicate:(nullable NSPredicate *)predicate
                                              sortedBy:(NSString *)sortTerm
                                             ascending:(BOOL)ascending;

@end

NS_ASSUME_NONNULL_END
