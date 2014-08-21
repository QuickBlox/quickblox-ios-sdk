//
//  QBContactList.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

/**
 QBContactList structure. Represents user's contact list
 */

@interface QBContactList : NSObject

/**
 Current contacts
 */
@property (atomic, readonly) NSArray *contacts;

/**
 Your requests which pending approval
 */
@property (atomic, readonly) NSArray *pendingApproval;

@end
