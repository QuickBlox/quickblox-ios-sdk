//
//  Enums.h
//  Quickblox
//
//  Created by IgorKh on 1/11/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBNullability.h"
#import <Quickblox/QBGeneric.h>

typedef NS_ENUM(NSUInteger, QBPresenseSubscriptionState) {
    QBPresenceSubscriptionStateNone = 1, // the user does not have a subscription to the contact's presence information, and the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateTo = 2, // the user has a subscription to the contact's presence information, but the contact does not have a subscription to the user's presence information
    QBPresenceSubscriptionStateFrom = 3, // the contact has a subscription to the user's presence information, but the user does not have a subscription to the contact's presence information
    QBPresenceSubscriptionStateBoth = 4, //  both the user and the contact have subscriptions to each other's presence information
};

typedef void(^QBUserLastActivityCompletionBlock)(NSUInteger seconds, NSError * QB_NULLABLE_S error);
typedef void(^QBPingCompleitonBlock)(NSTimeInterval timeInterval, BOOL success);
typedef void(^QBChatCompletionBlock)(NSError * _Nullable error);
typedef void(^QBChatDialogRequestOnlineUsersCompletionBlock)(NSMutableArray QB_GENERIC(NSNumber *) * _Nullable onlineUsers, NSError * _Nullable error);
typedef void(^QBChatDialogUserBlock)(NSUInteger userID);
