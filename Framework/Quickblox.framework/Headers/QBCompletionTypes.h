//
//  QBCompletionTypes.h
//  Pods
//
//  Created by Quickblox team on 20/04/2017.
//
//
#import <Foundation/Foundation.h>

@class QBChatDialog;
@class QBResponse;
@class QBResponsePage;
@class QBChatMessage;

NS_ASSUME_NONNULL_BEGIN
/**Block with response and created or updated chat dialog instances*/
typedef void(^qb_response_dialog_block_t) (QBResponse *response, QBChatDialog *tDialog);
/**Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance*/
typedef void(^qb_response_dialogs_block_t)(QBResponse *response, NSArray<QBChatDialog *> *dialogs, NSSet<NSNumber *> *dialogsUsersIDs,QBResponsePage *page);
/**Block with response deleted objects ids, not found objects ids and wrong permissions objects ids. */
typedef void(^qb_response_delete_dialog_block_t)(QBResponse *response, NSArray<NSString *> *deletedObjectsIDs, NSArray<NSString *> *notFoundObjectsIDs,NSArray<NSString *> *wrongPermissionsObjectsIDs);
/** Block with response and chat message instance */
typedef void(^qb_response_message_block_t)(QBResponse *response, QBChatMessage *tMessage);
/** Block with response instance and array of chat messages for page */
typedef void(^qb_response_messages_block_t)(QBResponse *response, NSArray<QBChatMessage *> *messages, QBResponsePage *page);
/**Block with response instance total unread count and dialogs dictionary. */
typedef void(^qb_response_unread_messages_block_t) (QBResponse *response, NSUInteger count, NSDictionary <NSString *, id> * dialogs);
/**Block with response instance and count */
typedef void(^qb_response_count_block_t) (QBResponse *response, NSUInteger count);

NS_ASSUME_NONNULL_END
