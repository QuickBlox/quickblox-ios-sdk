//
//  QBContactListItem.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEnums.h"

/**
 QBContactListItem structure. Represents user's contact list item
 */
@interface QBContactListItem : NSObject

/**
 Unique identifier of user
 */
@property (nonatomic, assign) NSUInteger userID;

/**
 User status (online/offline)
 */
@property (nonatomic, assign, getter=isOnline) BOOL online;

/**
 User subscription state. Read more about states http://xmpp.org/rfcs/rfc3921.html#roster
 */
@property (nonatomic, assign) QBPresenseSubscriptionState subscriptionState;

// Helpers: translate subscriptionState to and from string to and from enum
+ (QBPresenseSubscriptionState)subscriptionStateFromString:(NSString *)subscriptionState;
+ (NSString *)subscriptionStateToString:(QBPresenseSubscriptionState)subscriptionState;

@end
