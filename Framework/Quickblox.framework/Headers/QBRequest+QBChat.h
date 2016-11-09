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

NS_ASSUME_NONNULL_BEGIN

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
+ (QBRequest *)dialogsWithSuccessBlock:(nullable void(^)(QBResponse *response, NSArray QB_GENERIC(QBChatDialog *) * _Nullable dialogObjects, NSSet QB_GENERIC(NSNumber *) * _Nullable dialogsUsersIDs))successBlock
                            errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Retrieve chat dialogs for page
 
 @param page Page with skip and limit
 @param extendedRequest Set of request parameters
 @param successBlock Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)dialogsForPage:(QBResponsePage *)page
              extendedRequest:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                 successBlock:(nullable void(^)(QBResponse *response, NSArray QB_GENERIC(QBChatDialog *) * _Nullable dialogObjects, NSSet QB_GENERIC(NSNumber *) * _Nullable dialogsUsersIDs, QBResponsePage * _Nullable page))successBlock
                   errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Create chat dialog
 
 @param dialog chat dialog instance
 @param successBlock Block with response and created chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createDialog:(QBChatDialog *)dialog
               successBlock:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable createdDialog))successBlock
                 errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Update existing chat dialog
 
 @param dialog The dialog instance to update
 @param successBlock Block with response and updated chat dialog instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateDialog:(QBChatDialog *)dialog
               successBlock:(nullable void (^)(QBResponse *response, QBChatDialog * _Nullable chatDialog))successBlock
                 errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Delete dialogs
 
 @param dialogIDs The IDs of a dialogs to delete.
 @param forAllUsers Delete dialog for current user or remove it for all users.
 @param successBlock Block with response if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be owner of the dialog! If current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteDialogsWithIDs:(NSSet QB_GENERIC(NSString *) *)dialogIDs
                        forAllUsers:(BOOL)forAllUsers
                       successBlock:(nullable void(^)(QBResponse *response, NSArray QB_GENERIC(NSString *) * _Nullable deletedObjectsIDs, NSArray QB_GENERIC(NSString *) * _Nullable notFoundObjectsIDs, NSArray QB_GENERIC(NSString *) * _Nullable wrongPermissionsObjectsIDs))successBlock
                         errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Retrieve first 100 chat messages within particular dialog
 
 @param dialogID ID of a dialog
 @param successBlock Block with response instance and array of chat messages if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)messagesWithDialogID:(NSString *)dialogID
                       successBlock:(nullable void(^)(QBResponse *response, NSArray QB_GENERIC(QBChatMessage *) * _Nullable messages))successBlock
                         errorBlock:(nullable QBRequestErrorBlock)errorBlock;

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
+ (QBRequest *)messagesWithDialogID:(NSString *)dialogID
                    extendedRequest:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *) extendedParameters
                            forPage:(nullable QBResponsePage *)page
                       successBlock:(nullable void (^)(QBResponse *response, NSArray QB_GENERIC(QBChatMessage *) * _Nullable messages, QBResponsePage * _Nullable page))successBlock
                         errorBlock:(nullable QBRequestErrorBlock)errorBlock;
/**
 Create chat message.
 
 @param message Сhat message instance to create.
 @param successBlock Block with response and chat message instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createMessage:(QBChatMessage *)message
                successBlock:(nullable void(^)(QBResponse *response, QBChatMessage *createdMessage))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Update existing chat message - mark it as read.
 
 @note Updates message "read" status only on server.
 
 @param message Сhat message to update.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateMessage:(QBChatMessage *)message
                successBlock:(nullable void(^)(QBResponse *response))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Mark messages as read.
 
 @note Updates message "read" status only on server.
 
 @param messagesIDs Set of chat message IDs to mark as read. If messageIDs is nil then all messages in dialog will be marked as read.
 @param dialogID dialog ID.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)markMessagesAsRead:(nullable NSSet QB_GENERIC(NSString *) *)messagesIDs
                         dialogID:(NSString *)dialogID
                     successBlock:(nullable void(^)(QBResponse *response))successBlock
                       errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Mark messages as Delivered.
 
 @note Updates message "delivered" status only on server.
 
 @param messagesIDs Set of chat message IDs to mark as delivered. If messageIDs is nil then all messages in dialog will be marked as delivered.
 @param dialogID dialog ID.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)markMessagesAsDelivered:(nullable NSSet QB_GENERIC(NSString *) *)messagesIDs
                              dialogID:(NSString *)dialogID
                          successBlock:(nullable void(^)(QBResponse *response))successBlock
                            errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Delete existent chat messages completely for all users
 @param messageIDs The IDs of a messages to delete.
 @param forAllUsers Delete message for current user or remove it for all users.
 @param successBlock Block with response instance if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be owner of the message! If current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteMessagesWithIDs:(NSSet QB_GENERIC(NSString *) *)messageIDs
                         forAllUsers:(BOOL)forAllUsers
                        successBlock:(nullable void(^)(QBResponse *response))successBlock
                          errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Returns count of dialogs.
 
 @param parameters Dialogs filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfDialogsWithExtendedRequest:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters
                                    successBlock:(nullable void(^)(QBResponse *response, NSUInteger count)) successBlock
                                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Returns count of messages for dialog.
 
 @param dialogID Dialog ID of the chat messages.
 @param parameters Messages filter parameters.
 @param successBlock Block with response instance and count if request succeded.
 @param errorBlock Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfMessagesForDialogID:(NSString *)dialogID
                          extendedRequest:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters
                             successBlock:(nullable void(^)(QBResponse *response, NSUInteger count)) successBlock
                               errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 *  Returns unread message count for dialogs with ids. Includes total count for all dialogs for user also.
 *
 *  @param dialogIDs Array of dialog IDs.
 *  @param successBlock Block with response instance total unread count and dialogs dictionary.
 *  @param errorBlock Block with response instance if request failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)totalUnreadMessageCountForDialogsWithIDs:(NSSet QB_GENERIC(NSString *) *)dialogIDs
                                           successBlock:(nullable void(^)(QBResponse *response, NSUInteger count, NSDictionary QB_GENERIC(NSString *, id) * _Nullable dialogs))successBlock
                                             errorBlock:(nullable QBRequestErrorBlock)errorBlock;

@end

NS_ASSUME_NONNULL_END
