//
//  QMContactListCache.h
//  QMServices
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMDBStorage.h"

@interface QMContactListCache : QMDBStorage

#pragma mark - Singleton

/**
 *  Chat cache singleton
 *
 *  @return QMContactListCache instance
 */
+ (QMContactListCache *)instance;

#pragma mark - Configure store

/**
 *  Setup QMContactListCache stake wit store name
 *
 *  @param storeName Store name
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName;

/**
 *  Clean clean chat cache with store name
 *
 *  @param name Store name
 */
+ (void)cleanDBWithStoreName:(NSString *)name;

#pragma mark -
#pragma mark Dialogs
#pragma mark -
#pragma mark Insert / Update / Delete contact items

/**
 *  Insert/Update QBContactListItem in cache
 *
 *  @param contactListItems QBContactListItem instance
 *  @param completion       Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListItem:(QBContactListItem *)contactListItems
                           completion:(dispatch_block_t)completion;
/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactListItems Array of QBContactListItem instances
 *  @param completion       Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListWithItems:(NSArray *)contactListItems
                                completion:(dispatch_block_t)completion;

/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactList QBContactList instance
 *  @param completion  Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListItemsWithContactList:(QBContactList *)contactList
                                           completion:(dispatch_block_t)completion;
/**
 *  Delete ContactListItem from cache
 *
 *  @param contactListItem  QBContactListItem instance
 *  @param completion       Completion block is called after delete operation is completed
 */
- (void)deleteContactListItem:(QBContactListItem *)contactListItem
                   completion:(dispatch_block_t)completion;

/**
 *  Delete all contact list items
 *
 *  @param completion Completion block is called after delete contact list items operation is completed
 */
- (void)deleteContactList:(dispatch_block_t)completion;

#pragma mark Fetch ContactList operations

/**
 *  Fetch all contact list items
 *
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBContactListItem instances
 */
- (void)contactListItems:(void(^)(NSArray *contactListItems))completion;

/**
 *  Fetch contact list item wiht user ID
 *
 *  @param userID     userID which you would like to Fetch from cache
 *  @param completion Completion block that is called after the fetch has completed. Returns an instance of QBContactListItem
 */
- (void)contactListItemWithUserID:(NSUInteger)userID
                        completion:(void(^)(QBContactListItem *))completion;

#pragma mark -
#pragma mark  Users cahce
#pragma mark -
#pragma mark Insert / Update / Delete users

/**
 *  Insert/Update user in cache
 *
 *  @param user       QBUUser instance
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateUser:(QBUUser *)user
                completion:(dispatch_block_t)completion;
/**
 *  Insert/Update users in cache
 *
 *  @param users      Array of QBUUser instances
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateUsers:(NSArray *)users
                 completion:(dispatch_block_t)completion;
/**
 *  Delete user from cahce
 *
 *  @param user        QBUUser instance
 *  @param completion  Completion block that is called after the delete operation has completed.
 */
- (void)deleteUser:(QBUUser *)user
        completion:(dispatch_block_t)completion;
/**
 *  Delete all users
 *
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteAllUsers:(dispatch_block_t)completion;

#pragma mark Fetch users operations

/**
 *  Fetch user with predicate
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param completion Completion block that is called after the fetch has completed. Returns an instance of QBUUser
 */
- (void)userWithPredicate:(NSPredicate *)predicate
               completion:(void(^)(QBUUser *user))completion;

/**
 *  Fetch users with sort attribute, sorted ascending
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBUUser instances
 */
- (void)usersSortedBy:(NSString *)sortTerm
            ascending:(BOOL)ascending
           completion:(void(^)(NSArray *users))completion;
/**
 *  Fetch users with predicate, sort attribute, sorted ascending
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBUUser instances
 */
- (void)usersWithPredicate:(NSPredicate *)predicate
                  sortedBy:(NSString *)sortTerm
                 ascending:(BOOL)ascending
                completion:(void(^)(NSArray *users))completion;

@end
