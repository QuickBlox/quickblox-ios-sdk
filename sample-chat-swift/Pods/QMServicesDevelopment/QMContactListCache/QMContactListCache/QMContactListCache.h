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
+ (QB_NULLABLE QMContactListCache *)instance;

#pragma mark - Configure store

/**
 *  Setup QMContactListCache stake wit store name
 *
 *  @param storeName Store name
 */
+ (void)setupDBWithStoreNamed:(QB_NONNULL NSString *)storeName;

/**
 *  Clean clean chat cache with store name
 *
 *  @param name Store name
 */
+ (void)cleanDBWithStoreName:(QB_NONNULL NSString *)name;

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
- (void)insertOrUpdateContactListItem:(QB_NONNULL QBContactListItem *)contactListItems
                           completion:(QB_NULLABLE dispatch_block_t)completion;
/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactListItems Array of QBContactListItem instances
 *  @param completion       Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListWithItems:(QB_NONNULL NSArray QB_GENERIC(QBContactListItem *) *)contactListItems
                                completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactList QBContactList instance
 *  @param completion  Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListItemsWithContactList:(QB_NONNULL QBContactList *)contactList
                                           completion:(QB_NULLABLE dispatch_block_t)completion;
/**
 *  Delete ContactListItem from cache
 *
 *  @param contactListItem  QBContactListItem instance
 *  @param completion       Completion block is called after delete operation is completed
 */
- (void)deleteContactListItem:(QB_NONNULL QBContactListItem *)contactListItem
                   completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete all contact list items
 *
 *  @param completion Completion block is called after delete contact list items operation is completed
 */
- (void)deleteContactList:(QB_NULLABLE dispatch_block_t)completion;

#pragma mark Fetch ContactList operations

/**
 *  Fetch all contact list items
 *
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBContactListItem instances
 */
- (void)contactListItems:(void(^QB_NULLABLE_S)(NSArray QB_GENERIC(QBContactListItem *) * QB_NULLABLE_S contactListItems))completion;

/**
 *  Fetch contact list item wiht user ID
 *
 *  @param userID     userID which you would like to Fetch from cache
 *  @param completion Completion block that is called after the fetch has completed. Returns an instance of QBContactListItem
 */
- (void)contactListItemWithUserID:(NSUInteger)userID
                       completion:(void(^QB_NULLABLE_S)(QBContactListItem * QB_NULLABLE_S contactListItems))completion;


@end
