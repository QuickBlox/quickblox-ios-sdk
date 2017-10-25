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

@end

NS_ASSUME_NONNULL_END
