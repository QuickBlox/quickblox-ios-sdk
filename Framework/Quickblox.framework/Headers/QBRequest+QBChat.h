//
//  QBRequest+QBChat.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 9/1/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
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
+ (QB_NONNULL QBRequest *)dialogsWithSuccessBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) * QB_NULLABLE_S dialogObjects, NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs))successBlock
                                       errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve chat dialogs for page
 
 @param page Page with skip and limit
 @param extendedRequest Set of request parameters
 @param successBlock Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)dialogsForPage:(QB_NULLABLE QBResponsePage *)page
                         extendedRequest:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                            successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) * QB_NULLABLE_S dialogObjects,NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs, QBResponsePage * QB_NULLABLE_S page))successBlock
                              errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Create chat dialog
 
 @param dialog chat dialog instance
 @param successBlock Block with response and created chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createDialog:(QB_NONNULL QBChatDialog *)dialog
                          successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBChatDialog * QB_NULLABLE_S createdDialog))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Update existing chat dialog
 
 @param dialog The dialog instance to update
 @param successBlock Block with response and updated chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateDialog:(QB_NONNULL QBChatDialog *)dialog
                          successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBChatDialog * QB_NULLABLE_S chatDialog))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Delete dialogs
 
 @param dialogIDs The IDs of a dialogs to delete.
 @param forAllUsers Delete dialog for current user or remove it for all users.
 @param successBlock Block with response if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be owner of the dialog! If current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteDialogsWithIDs:(QB_NONNULL NSSet QB_GENERIC(NSString *) *)dialogIDs
                                   forAllUsers:(BOOL)forAllUsers
                                  successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(NSString *) * QB_NULLABLE_S deletedObjectsIDs, NSArray QB_GENERIC(NSString *) * QB_NULLABLE_S notFoundObjectsIDs, NSArray QB_GENERIC(NSString *) * QB_NULLABLE_S wrongPermissionsObjectsIDs))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve first 100 chat messages within particular dialog
 
 @param dialogID ID of a dialog
 @param successBlock Block with response instance and array of chat messages if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)messagesWithDialogID:(QB_NONNULL NSString *)dialogID
                                  successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBChatMessage *) * QB_NULLABLE_S messages))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve chat messages within particular dialog for page.
 
 @param dialogID ID of a dialog.
 @param extendedParameters A set of additional request parameters.
 @param page response page instance.
 @param successBlock Block with response instance and array of chat messages for page if request succeded
 @param errorBlock Block with response instance if request failed
 
 @discussion By default all messages retrieved from server is marked as read, if you need another behaviour please use mark_as_read parameter in extendedParameters dictionary.
 
 @code
 [extendedParameters setObject:@"0" forKey:@"mark_as_read"];
 @endcode
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)messagesWithDialogID:(QB_NONNULL NSString *)dialogID
                               extendedRequest:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *) extendedParameters
                                       forPage:(QB_NULLABLE QBResponsePage *)page
                                  successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBChatMessage *) * QB_NULLABLE_S messages, QBResponsePage * QB_NULLABLE_S page))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;
/**
 Create chat message.
 
 @param message Сhat message instance to create.
 @param successBlock Block with response and chat message instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createMessage:(QB_NONNULL QBChatMessage *)message
                           successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBChatMessage * QB_NONNULL_S createdMessage))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Update existing chat message - mark it as read.
 
 @note Updates message "read" status only on server.
 
 @param message Сhat message to update.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateMessage:(QB_NONNULL QBChatMessage *)message
                           successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Mark messages as read.
 
 @note Updates message "read" status only on server.
 
 @param dialogID dialog ID.
 @param messagesIDs Set of chat message IDs to mark as read. If messageIDs is nil then all messages in dialog will be marked as read.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QB_NONNULL QBRequest *)markMessagesAsRead:(QB_NULLABLE NSSet QB_GENERIC(NSString *) *)messagesIDs
                                    dialogID:(QB_NONNULL NSString *)dialogID
                                successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                                  errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Delete existent chat messages completely for all users
 @param messageIDs The IDs of a messages to delete.
 @param forAllUsers Delete message for current user or remove it for all users.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be owner of the message! If current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteMessagesWithIDs:(QB_NONNULL NSSet QB_GENERIC(NSString *) *)messageIDs
                                    forAllUsers:(BOOL)forAllUsers
                                   successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response))successBlock
                                     errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Returns count of dialogs.
 
 @param parameters Dialogs filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)countOfDialogsWithExtendedRequest:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters
                                               successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSUInteger count)) successBlock
                                                 errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Returns count of messages for dialog.
 
 @param dialogID Dialog ID of the chat messages.
 @param parameters Messages filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)countOfMessagesForDialogID:(QB_NONNULL NSString *)dialogID
                                     extendedRequest:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters
                                        successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSUInteger count)) successBlock
                                          errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 *  Returns unread message count for dialogs with ids. Includes total count for all dialogs for user also.
 *
 *  @param dialogIDs Array of dialog IDs.
 *  @param successBlock Block with response instance total unread count and dialogs dictionary.
 *  @param errorBlock Block with response instance if request failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)totalUnreadMessageCountForDialogsWithIDs:(QB_NONNULL NSSet QB_GENERIC(NSString *) *)dialogIDs
                                                      successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSUInteger count, NSDictionary QB_GENERIC(NSString *, id) * QB_NULLABLE_S dialogs))successBlock
                                                        errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

@end
