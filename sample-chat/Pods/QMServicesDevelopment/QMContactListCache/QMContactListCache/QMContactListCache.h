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


@end
