//
//  QBRequest+QBChat.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 9/1/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequest.h"

@class QBResponsePage;
@class QBChatMessage;
@class QBChatDialog;

@interface QBRequest (QBChat)

/**
 Retrieve chat dialogs
 
 @param successBlock Block with response instance and arrays of chat dialogs and chat dialogs users IDs if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)dialogsWithSuccessBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve chat dialogs for page
 
 @param page Page with skip and limit
 @param extendedParameters Set of request parameters
 @param successBlock Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)dialogsForPage:(QBResponsePage *)page extendedRequest:(NSDictionary *)extendedRequest
                 successBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page))successBlock
                   errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Create chat dialog
 
 @param dialog chat dialog instance
 @param successBlock Block with response and created chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createDialog:(QBChatDialog *)dialog successBlock:(void(^)(QBResponse *response, QBChatDialog *createdDialog))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Update existing chat dialog
 
 @param dialog. The dialog instance to update
 @param successBlock Block with response and updated chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateDialog:(QBChatDialog *)dialog  successBlock:(void (^)(QBResponse *, QBChatDialog *))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete a dialog
 
 @param dialogID. The ID of a dialog to delete
 @param successBlock Block with response if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteDialogWithID:(NSString *)dialogID successBlock:(void(^)(QBResponse *responce))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve first 100 chat messages within particular dialog
 
 @param dialogID ID of a dialog
 @param successBlock Block with response instance and array of chat messages if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)messagesWithDialogID:(NSString *)dialogID successBlock:(void(^)(QBResponse *response, NSArray *messages))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve chat messages within particular dialog for page
 
 @param dialogID ID of a dialog
 @param extendedParameters A set of additional request parameters
 @param page response page instance
 @param successBlock Block with response instance and array of chat messages for page if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)messagesWithDialogID:(NSString *)dialogID extendedRequest:(NSDictionary *) extendedParameters
                            forPage:(QBResponsePage *)page
                       successBlock:(void (^)(QBResponse *, NSArray *, QBResponsePage *))successBlock
                         errorBlock:(QBRequestErrorBlock)errorBlock ;
/**
 Create chat message
 
 @param message Сhat message instance to create
 @param successBlock Block with response and chat message instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createMessage:(QBChatMessage *)message successBlock:(void(^)(QBResponse *response, QBChatMessage *createdMessage))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Update existing chat message - mark it as read
 
 @param message Сhat message to update
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateMessage:(QBChatMessage *)message successBlock:(void(^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Mark messages as read
 
 @param dialogID dialog ID
 @param messageIDs set of chat message IDs to mark as read. If messageIDs is nil then all messages in dialog will be marked as read.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)markMessagesAsRead:(NSSet *)messagesIDs dialogID:(NSString *)dialogID successBlock:(void(^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete existent chat message
 
 @param messageID Message ID to delete
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteMessageWithID:(NSString *)messageID successBlock:(void(^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete existent chat messages
 
 @param messageIDs Set of message IDs to delete
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteMessagesWithIDs:(NSSet *)messageIDs successBlock:(void(^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Returns count of dialogs.
 
 @param parameters Dialogs filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfDialogsWithExtendedRequest:(NSDictionary *)parameters successBlock:(void(^)(QBResponse * response, NSUInteger count)) successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Returns count of messages for dialog.
 
 @param dialogID Dialog ID of the chat messages.
 @param parameters Messages filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfMessagesForDialogID:(NSString *)dialogID
                          extendedRequest:(NSDictionary *)parameters
                             successBlock:(void(^)(QBResponse * response, NSUInteger count)) successBlock
                               errorBlock:(QBRequestErrorBlock)errorBlock;

@end
