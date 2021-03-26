//
//  QBContactListItem.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, QBPresenseSubscriptionState) {
    //The user does not have a subscription to the contact's presence information, and the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateNone = 1,
    //The user has a subscription to the contact's presence information, but the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateTo = 2,
    //The contact has a subscription to the user's presence information, but the user does not have a subscription to the contact's presence information
    QBPresenceSubscriptionStateFrom = 3,
    //Both the user and the contact have subscriptions to each other's presence information
    QBPresenceSubscriptionStateBoth = 4,
};

/**
 QBContactListItem class interface.
 Represents user's contact list item.
 */
@interface QBContactListItem : NSObject

/**
 Unique identifier of user.
 */
@property (nonatomic, assign) NSUInteger userID;

/**
 User status (online/offline).
 */
@property (nonatomic, assign, getter=isOnline) BOOL online;

/**
 User subscription state. Read more about states http://xmpp.org/rfcs/rfc3921.html#roster
 */
@property (nonatomic, assign) QBPresenseSubscriptionState subscriptionState;

@end

@interface QBContactListItem(Internal)
// Helpers: translate subscriptionState to and from string to and from enum
+ (QBPresenseSubscriptionState)subscriptionStateFromString:(nullable NSString *)subscriptionState;
@end

NS_ASSUME_NONNULL_END
