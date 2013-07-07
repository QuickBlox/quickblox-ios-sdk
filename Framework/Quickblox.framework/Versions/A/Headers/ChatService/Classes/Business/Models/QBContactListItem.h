//
//  QBContactListItem.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBContactListItem structure. Represents user's contact list item
 */

@interface QBContactListItem : NSObject{
@private
    NSUInteger userID;
    BOOL online;
}

/**
 Unique identifier of user
 */
@property (atomic, assign) NSUInteger userID;

/**
 User status (online/offline)
 */
@property (atomic, assign, getter=isOnline) BOOL online;

@end
