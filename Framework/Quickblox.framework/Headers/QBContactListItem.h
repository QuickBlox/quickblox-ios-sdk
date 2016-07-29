//
//  QBContactListItem.h
//  Quickblox
//
//  Created by IgorKh on 3/18/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "ChatEnums.h"

extern NSString *QB_NONNULL_S const kPresenceSubscriptionStateNone;
extern NSString *QB_NONNULL_S const kPresenceSubscriptionStateTo;
extern NSString *QB_NONNULL_S const kPresenceSubscriptionStateFrom;
extern NSString *QB_NONNULL_S const kPresenceSubscriptionStateBoth;

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
+ (QBPresenseSubscriptionState)subscriptionStateFromString:(QB_NULLABLE NSString *)subscriptionState;
+ (QB_NULLABLE NSString *)subscriptionStateToString:(QBPresenseSubscriptionState)subscriptionState;

@end
