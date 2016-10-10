//
//  QMContactListMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 25.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Contact list memory storage
 */
@interface QMContactListMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 *  Update memory storage with QBContactList instance.
 *
 *  @param contactList QBContactList instance
 */
- (void)updateWithContactList:(QBContactList *)contactList;

/**
 *  Update memory storage with QBContactLists items.
 *
 *  @param contactLists QBContactList items
 */
- (void)updateWithContactListItems:(NSArray QB_GENERIC(QBContactListItem *) *)contactListItems;

/**
 *  Find QBContactListItem by user ID.
 *
 *  @param userID NSUInteger user ID
 *
 *  @return finded QBContactListItem instance
 */
- (nullable QBContactListItem *)contactListItemWithUserID:(NSUInteger)userID;

/**
 *  Get all stored User IDs.
 *
 *  @return array of user IDs
 */
- (NSArray QB_GENERIC(NSNumber *) *)userIDsFromContactList;

/**
 *  Get all stored contact list items.
 *
 *  @return array of contact list items.
 */
- (NSArray QB_GENERIC(QBContactListItem *) *)allContactListItems;

@end

NS_ASSUME_NONNULL_END
