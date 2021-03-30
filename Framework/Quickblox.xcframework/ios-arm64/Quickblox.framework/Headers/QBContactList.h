//
//  QBContactList.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickBlox/QBContactListItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 QBContactList class interface.
 Represents user's contact list.
 */
@interface QBContactList : NSObject

/**
 Current contacts.
 */
@property (nonatomic, readonly, nullable) NSArray<QBContactListItem *> *contacts;

/**
 *  Your requests which pending approval.
 */
@property (nonatomic, readonly, nullable) NSArray<QBContactListItem *> *pendingApproval;


/**
 How to use:
 QBContactListItem *item = QBChat.instance.contactList[userID];

 @param userID userID.
 @return QBContactListItem isnstance if exist.
 */
- (nullable QBContactListItem *)objectAtIndexedSubscript:(NSUInteger)userID;

/**
 Sorted by state

 @param state @see QBPresenseSubscriptionState
 @return Array of QBContactListItem items
 */
- (NSArray<QBContactListItem *> *)itemsSortedByState:(QBPresenseSubscriptionState)state;


@end

NS_ASSUME_NONNULL_END
