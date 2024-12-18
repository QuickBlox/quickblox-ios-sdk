//
//  QBRequest+QBChat.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickBlox/QBRequest.h>
#import <QuickBlox/QBCompletionTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBChat)

/**
 Retrieve chat dialogs for page
 
 @param page Page with skip and limit
 @param extendedRequest Set of request parameters
 @param successBlock Block with response instance, arrays of chat dialogs and chat dialogs users IDs and page instance if the request is succeeded
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)dialogsForPage:(QBResponsePage *)page
              extendedRequest:(nullable NSDictionary<NSString *, NSString *> *)extendedRequest
                 successBlock:(nullable qb_response_dialogs_block_t)successBlock
                   errorBlock:(nullable qb_response_block_t)errorBlock;

/// Creates a chat dialog.
/// @param dialog The chat dialog instance to be created.
/// @param completion A block called upon completion of the operation.
///        - `tDialog`: The created chat dialog instance, or `nil` if an error occurred.
///        - `error`: An error object describing the failure, or `nil` if the operation succeeded.
+ (void)createDialog:(QBChatDialog *)dialog
          completion:(void (^)(QBChatDialog * _Nullable tDialog,
                               NSError * _Nullable error))completion;

/**
 Create chat dialog
 
 @param dialog chat dialog instance
 @param successBlock Block with response and created chat dialog instances if the request is succeeded
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createDialog:(QBChatDialog *)dialog
               successBlock:(nullable qb_response_dialog_block_t)successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Update existing chat dialog
 
 @param dialog The dialog instance to update
 @param successBlock Block with response and updated chat dialog instances if the request is succeeded
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateDialog:(QBChatDialog *)dialog
               successBlock:(nullable qb_response_dialog_block_t)successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

/// Deletes dialogs with specified IDs.
///
/// @param dialogIDs A set of dialog IDs to delete.
/// @param forAllUsers Specifies whether the dialog should be deleted for all users.
///                    Pass `YES` to delete for all users (current user must be the owner),
///                    or `NO` to delete only for the current user.
/// @param completion A block called upon completion of the request, containing:
///        - `deletedIds`: An array of dialog IDs successfully deleted.
///        - `notFoundIds`: An array of dialog IDs that were not found.
///        - `wrongPermissionsIds`: An array of dialog IDs for which the current user lacks the necessary permissions.
///        - `error`: An error object if the request fails, or `nil` if it succeeds.
///
/// @discussion When passing `YES` to `forAllUsers`, the current user must be the owner of the dialog.
///             If the user is not the owner, the request will fail.
+ (void)deleteDialogsWithIDs:(NSSet<NSString *> *)dialogIDs
                 forAllUsers:(BOOL)forAllUsers
                  completion:(qb_response_delete_dialog_completion_t)completion;
/**
 Delete dialogs
 
 @param dialogIDs The IDs of a dialogs to delete.
 @param forAllUsers Delete dialog for current user or remove it for all users.
 @param successBlock Block with response if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be owner of the dialog! If current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteDialogsWithIDs:(NSSet<NSString *> *)dialogIDs
                        forAllUsers:(BOOL)forAllUsers
                       successBlock:(nullable qb_response_delete_dialog_block_t)successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;

/// Retrieves chat messages for a specific dialog and page.
///
/// - Parameters:
///   - dialogID: The unique identifier of the dialog.
///   - extendedParameters: A dictionary of additional request parameters. Use the key `@"mark_as_read"` with value `@"0"`
///     to prevent marking messages as read upon retrieval.
///   - page: An optional instance of `QBResponsePage` specifying the pagination details.
///   - completion: A completion block that returns an array of `QBChatMessage` objects for the specified page,
///     the response page details, and an error object if the operation fails.
///
/// By default, all messages retrieved from the server are marked as read. To change this behavior,
/// include the `@"mark_as_read"` parameter in the `extendedParameters` dictionary.
///
/// ```objective-c
/// [extendedParameters setObject:@"0" forKey:@"mark_as_read"];
/// ```
+ (void)messagesWithDialogID:(NSString *)dialogID
             extendedRequest:(nullable NSDictionary<NSString *, NSString *> *) extendedParameters
                     forPage:(nullable QBResponsePage *)page
                  completion:(nullable qb_response_messages_completion_t)completion;

/**
 Retrieve chat messages within particular dialog for page.
 
 @param dialogID ID of a dialog.
 @param extendedParameters A set of additional request parameters.
 @param page response page instance.
 @param successBlock Block with response instance and array of chat messages for page if the request is succeeded
 @param errorBlock Block with response instance if the request is failed.
 
 @discussion By default all messages retrieved from server is marked as read, if you need another behaviour please use mark_as_read parameter in extendedParameters dictionary.
 
 @code
 [extendedParameters setObject:@"0" forKey:@"mark_as_read"];
 @endcode
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)messagesWithDialogID:(NSString *)dialogID
                    extendedRequest:(nullable NSDictionary<NSString *, NSString *> *) extendedParameters
                            forPage:(nullable QBResponsePage *)page
                       successBlock:(nullable qb_response_messages_block_t)successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;
/**
 Create chat message.
 
 @param message Сhat message instance to create.
 @param successBlock Block with response and chat message instance if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createMessage:(QBChatMessage *)message
                successBlock:(nullable qb_response_message_block_t)successBlock
                  errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Create and send message to chat.
 
 @param message Сhat message instance to create.
 @param successBlock Block with response and chat message instance if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)sendMessage:(QBChatMessage *)message
              successBlock:(nullable qb_response_message_block_t)successBlock
                errorBlock:(nullable qb_response_block_t)errorBlock;
/**
 Mark messages as read.
 
 @note Updates message "read" status only on server.
 
 @param messagesIDs Set of chat message IDs to mark as read. If messageIDs is nil then all messages in dialog will be marked as read.
 @param dialogID dialog ID.
 @param successBlock Block with response instance if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)markMessagesAsRead:(nullable NSSet<NSString *> *)messagesIDs
                         dialogID:(NSString *)dialogID
                     successBlock:(nullable qb_response_block_t)successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Mark messages as Delivered.
 
 @note Updates message "delivered" status only on server.
 
 @param messagesIDs Set of chat message IDs to mark as delivered. If messageIDs is nil then all messages in dialog will be marked as delivered.
 @param dialogID dialog ID.
 @param successBlock Block with response instance if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)markMessagesAsDelivered:(nullable NSSet<NSString *> *)messagesIDs
                              dialogID:(NSString *)dialogID
                          successBlock:(nullable qb_response_block_t)successBlock
                            errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Update message text.
 
 @note Updates message text only on server.
 
 @param messagesID message ID.
 @param text Updated message text.
 @param dialogID dialog ID.
 @param successBlock Block with response instance if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateMessageWithID:(NSString *)messageID
                              text:(NSString *)text
                          dialogID:(NSString *)dialogID
                      successBlock:(nullable qb_response_block_t)successBlock
                        errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Delete existent chat messages completely for all users
 @param messageIDs The IDs of messages to delete.
 @param forAllUsers Delete message for the current user or remove it for all users.
 @param successBlock Block with response instance if the request succeeded.
 @param errorBlock Block with response instance if the request failed.
 
 @discussion Passing YES to 'forAllUsers' requires current user to be the owner of the message! If the current user is not the owner - request fails.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteMessagesWithIDs:(NSSet<NSString *> *)messageIDs
                         forAllUsers:(BOOL)forAllUsers
                        successBlock:(nullable qb_response_block_t)successBlock
                          errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Returns count of dialogs.
 
 @param parameters Dialogs filter parameters.
 @param successBlock Block with response instance and count if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfDialogsWithExtendedRequest:(nullable NSDictionary<NSString *, NSString *> *)parameters
                                    successBlock:(nullable qb_response_count_block_t) successBlock
                                      errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Returns count of messages for dialog.
 
 @param dialogID Dialog ID of the chat messages.
 @param parameters Messages filter parameters.
 @param successBlock Block with response instance and count if the request is succeeded.
 @param errorBlock Block with response instance if the request is failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)countOfMessagesForDialogID:(NSString *)dialogID
                          extendedRequest:(nullable NSDictionary<NSString *, NSString *> *)parameters
                             successBlock:(nullable qb_response_count_block_t) successBlock
                               errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 *  Returns unread message count for dialogs with ids. Includes total count for all dialogs for user also.
 *
 *  @param dialogIDs Array of dialog IDs.
 *  @param successBlock Block with response instance total unread count and dialogs dictionary.
 *  @param errorBlock Block with response instance if the request is failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)totalUnreadMessageCountForDialogsWithIDs:(NSSet <NSString *> *)dialogIDs
                                           successBlock:(nullable qb_response_unread_messages_block_t)successBlock
                                             errorBlock:(nullable qb_response_block_t)errorBlock;
//MARK: Notifications settings

/**
 Get the notifications settings status.
 
 @param dialogID Dialog ID
 @param successBlock Block with current status of notifications settings.
 @param errorBlock errorBlock Block with response instance if the request is failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)notificationsSettingsForDialogID:(NSString *)dialogID
                                   successBlock:(nullable void(^)(BOOL enabled))successBlock
                                     errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 User can turn YES/NO push notifications for offline messages in a dialog. Default value is YES.
 By default when a user is offline and other user sent a message to him then he will receive a push
 notification. It is possible to disable this feature.
 
 @param dialogID Dialog ID
 @param enable YES / NO
 @param successBlock Block with current status of notifications settings.
 @param errorBlock errorBlock Block with response instance if the request is failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateNotificationsSettingsForDialogID:(NSString *)dialogID
                                               enable:(BOOL)enable
                                         successBlock:(nullable void(^)(BOOL enabled))successBlock
                                           errorBlock:(nullable qb_response_block_t)errorBlock;

@end

NS_ASSUME_NONNULL_END
