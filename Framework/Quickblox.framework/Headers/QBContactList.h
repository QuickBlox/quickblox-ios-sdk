//
//  QBContactList.h
//  Quickblox
//
//  Created by QuickBlox team on 3/18/13.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import "QBChatTypes.h"

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
@property (nonatomic, readonly, nullable) NSArray<QBContactListItem *> *contacts;

/**
 *  Your requests which pending approval.
 */
@property (nonatomic, readonly, nullable) NSArray<QBContactListItem *> *pendingApproval;

/**
 *  Get last activity
 *
 *  @param item     QBContactListItem
 *  @param completion completion block with last activity in seconds and error
 *  @warning Deprecated in 2.10.
 */
- (void)lastActivityForContactListItem:(QBContactListItem *)item
                        withCompletion:(QBUserLastActivityCompletionBlock)completion;
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.10. Use - [QBChat lastActivityForUserID:completion:]");
/**
 *  Get last activity
 *
 *  @param item       QBContactListItem
 *  @param timeout    timeout
 *  @param completion completion block with last activity in seconds and error
 *  @warning Deprecated in 2.10.
 */
- (void)lastActivityForContactListItem:(QBContactListItem *)item
                           withTimeout:(NSTimeInterval)timeout
                            completion:(QBUserLastActivityCompletionBlock)completion
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.10. Use - [QBChat lastActivityForUserID:withTimeout:completion:]");

@end

NS_ASSUME_NONNULL_END
