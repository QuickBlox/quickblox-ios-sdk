//
//  Enums.h
//  Quickblox
//
//  Created by IgorKh on 1/11/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBNullability.h"
#import <Quickblox/QBGeneric.h>

typedef NS_ENUM(NSUInteger, QBPresenceShow) {
    QBPresenceShowAway = 1, // The entity or resource is temporarily away.
    QBPresenceShowChat = 2, // The entity or resource is actively interested in chatting.
    QBPresenceShowDND = 3, // The entity or resource is busy (dnd = "Do Not Disturb").
    QBPresenceShowXA = 4, // The entity or resource is away for an extended period (xa = "eXtended Away").
} DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.1. This enum is unused and will be removed in a future versions.");

typedef NS_ENUM(NSUInteger, QBPresenseSubscriptionState){
    QBPresenceSubscriptionStateNone = 1, // the user does not have a subscription to the contact's presence information, and the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateTo = 2, // the user has a subscription to the contact's presence information, but the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateFrom = 3, // the contact has a subscription to the user's presence information, but the user does not have a subscription to the contact's presence information
    QBPresenceSubscriptionStateBoth = 4, //  both the user and the contact have subscriptions to each other's presence information
};

typedef NS_ENUM(NSUInteger, QBChatDialogType) {
    QBChatDialogTypePublicGroup = 1,
    QBChatDialogTypeGroup = 2,
    QBChatDialogTypePrivate = 3,
};

typedef void(^QBPingCompleitonBlock)(NSTimeInterval timeInterval, BOOL success);
typedef void(^QBChatCompletionBlock)(NSError* QB_NULLABLE_S error);
typedef void(^QBChatDialogBlockedMessageBlock)(NSError * QB_NULLABLE_S error) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatCompletionBlock instead.");
typedef void(^QBChatDialogRequestOnlineUsersCompletionBlock)(NSMutableArray QB_GENERIC(NSNumber *) * QB_NULLABLE_S onlineUsers, NSError* QB_NULLABLE_S error);
typedef void(^QBChatDialogUserBlock)(NSUInteger userID);
