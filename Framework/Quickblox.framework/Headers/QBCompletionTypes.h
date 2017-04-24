//
//  QBCompletionTypes.h
//  Pods
//
//  Created by Andrey Ivanov on 20/04/2017.
//
//
#import <Foundation/Foundation.h>

@class QBChatDialog;
@class QBResponse;
@class QBResponsePage;
@class QBChatMessage;

NS_ASSUME_NONNULL_BEGIN
/**
 @param response QBResponse instance
 @param tDialog QBChatDialog instance
 */
typedef void(^qb_dialog_block_t) (

    QBResponse *response,
    QBChatDialog *tDialog
);

/**
 Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance
 if request succeded
 
 @param response QBResponse instance
 @param dialogObjects array of chat dialogs
 @param dialogsUsersIDs set of user IDs
 @param page QBResponsePage instance
 */
typedef void(^qb_dialogs_block_t)(

    QBResponse *response,
    NSArray<QBChatDialog *> *dialogs,
    NSSet<NSNumber *> *dialogsUsersIDs,
    QBResponsePage *page
);

/**
 Block with response if request succeded.
 
 @param response response description
 @param deletedObjectsIDs deletedObjectsIDs description
 @param notFoundObjectsIDs notFoundObjectsIDs description
 @param wrongPermissionsObjectsIDs wrongPermissionsObjectsIDs description
 */
typedef void(^qb_delete_dialog_block_t)(

    QBResponse *response,
    NSArray<NSString *> *deletedObjectsIDs,
    NSArray<NSString *> *notFoundObjectsIDs,
    NSArray<NSString *> *wrongPermissionsObjectsIDs
);

/**
 Block with response and chat message instance if request succeded.
 
 @param response response description
 @param createdMessage createdMessage description
 */
typedef void(^qb_message_block_t)(
    QBResponse *response,
    QBChatMessage *tMessage
);

/**
 Block with response instance and array of chat messages for page if request succeded
 
 @param response response description
 @param messages array of chat messages
 @param page page description
 */
typedef void(^qb_messages_block_t)(

    QBResponse *response,
    NSArray<QBChatMessage *> *messages,
    QBResponsePage *page
);

/**
 Block with response instance total unread count and dialogs dictionary.
 
 @param response response description
 @param count count description
 @param <NSString <NSString description
 @param dialogs dialogs description
 */
typedef void(^qb_unread_messages_block_t) (

    QBResponse *response,
    NSUInteger count,
    NSDictionary <NSString *, id> * dialogs
);

/**
 Block with response instance and count if request succeded.
 
 @param response response description
 @param count count description
 */
typedef void(^qb_count_block_t) (

    QBResponse *response,
    NSUInteger count
);

NS_ASSUME_NONNULL_END
