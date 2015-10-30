//
//  Enums.h
//  Quickblox
//
//  Created by IgorKh on 1/11/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBNullability.h"
#import <Quickblox/QBGeneric.h>

typedef NS_ENUM(NSUInteger, QBPresenseShow) {
    QBPresenseShowAway = 1, // The entity or resource is temporarily away.
    QBPresenseShowChat = 2, // The entity or resource is actively interested in chatting.
    QBPresenseShowDND = 3, // The entity or resource is busy (dnd = "Do Not Disturb").
    QBPresenseShowXA = 4, // The entity or resource is away for an extended period (xa = "eXtended Away").
};

typedef NS_ENUM(NSUInteger, QBPresenseSubscriptionState){
    QBPresenseSubscriptionStateNone = 1, // the user does not have a subscription to the contact's presence information, and the contact does not have a subscription to the user's presence information
    QBPresenseSubscriptionStateTo = 2, // the user has a subscription to the contact's presence information, but the contact does not have a subscription to the user's presence information
    QBPresenseSubscriptionStateFrom = 3, // the contact has a subscription to the user's presence information, but the user does not have a subscription to the contact's presence information
    QBPresenseSubscriptionStateBoth = 4, //  both the user and the contact have subscriptions to each other's presence information
};

typedef NS_ENUM(NSUInteger, QBChatDialogType) {
    QBChatDialogTypePublicGroup = 1,
    QBChatDialogTypeGroup = 2,
    QBChatDialogTypePrivate = 3,
};

typedef void(^QBChatCompletionBlock)(NSError* QB_NULLABLE_S error);
typedef void(^QBChatDialogRequestOnlineUsersCompletionBlock)(NSMutableArray QB_GENERIC(NSNumber *) * QB_NULLABLE_S onlineUsers, NSError* QB_NULLABLE_S error);
