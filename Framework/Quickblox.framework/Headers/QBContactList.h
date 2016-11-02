//
//  QBContactList.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "ChatEnums.h"

NS_ASSUME_NONNULL_BEGIN

@class QBContactListItem;

/**
 *  QBContactList class interface.
 *  Represents user's contact list.
 */
@interface QBContactList : NSObject

/**
 *  Current contacts.
 */
@property (nonatomic, readonly, nullable) NSArray QB_GENERIC(QBContactListItem *) *contacts;

/**
 *  Your requests which pending approval.
 */
@property (nonatomic, readonly, nullable) NSArray QB_GENERIC(QBContactListItem *) *pendingApproval;

/**
 *  Get last activity
 *
 *  @param item     QBContactListItem
 *  @param completion completion block with last activity in seconds and error
 */
- (void)lastActivityForContactListItem:(QBContactListItem *)item
                        withCompletion:(QBUserLastActivityCompletionBlock)completion;
/**
 *  Get last activity
 *
 *  @param item       QBContactListItem
 *  @param timeout    timeout
 *  @param completion completion block with last activity in seconds and error
 */
- (void)lastActivityForContactListItem:(QBContactListItem *)item
                           withTimeout:(NSTimeInterval)timeOut
                            completion:(QBUserLastActivityCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
