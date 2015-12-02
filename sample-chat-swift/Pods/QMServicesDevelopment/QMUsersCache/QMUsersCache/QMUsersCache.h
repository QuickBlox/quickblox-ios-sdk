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

@interface QMUsersCache : QMDBStorage

+ (QMUsersCache *)instance;

#pragma mark - Insert/Update/Delete users in cache
/**
 *  Insert/Update user in cache
 *
 *  @param user       QBUUser instance
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (BFTask *)insertOrUpdateUser:(QBUUser *)user;
/**
 *  Insert/Update users in cache
 *
 *  @param users      Array of QBUUser instances
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (BFTask *)insertOrUpdateUsers:(NSArray QB_GENERIC(QBUUser *) *)users;
/**
 *  Delete user from cahce
 *
 *  @param user        QBUUser instance
 *  @param completion  Completion block that is called after the delete operation has completed.
 */
- (BFTask *)deleteUser:(QBUUser *)user;
/**
 *  Delete all users
 *
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (BFTask *)deleteAllUsers;

#pragma mark - Fetch users

/**
 *  Fetch user with predicate
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param completion Completion block that is called after the fetch has completed. Returns an instance of QBUUser
 */
- (BFTask QB_GENERIC(QBUUser *) *)userWithPredicate:(NSPredicate *) predicate;
/**
 *  Fetch users with sort attribute, sorted ascending
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBUUser instances
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)usersSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
/**
 *  Fetch users with predicate, sort attribute, sorted ascending
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBUUser instances
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)usersWithPredicate:(NSPredicate *)predicate
                                            sortedBy:(NSString *)sortTerm
                                           ascending:(BOOL)ascending;

@end
