//
//  QBContactList.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

/**
 QBContactList structure. Represents user's contact list
 */

@class QBContactListItem;

@interface QBContactList : NSObject

/**
 Current contacts
 */
@property (atomic, readonly, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(QBContactListItem *) * contacts;

/**
 Your requests which pending approval
 */
@property (atomic, readonly, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(QBContactListItem *) * pendingApproval;

@end
