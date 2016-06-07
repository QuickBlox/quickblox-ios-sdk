//
//  QMChatService.h
//  QMServices
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"
#import "QMDialogsMemoryStorage.h"
#import "QMMessagesMemoryStorage.h"
#import "QMChatAttachmentService.h"
#import "QMChatTypes.h"
#import "QMChatConstants.h"

@protocol QMChatServiceDelegate;
@protocol QMChatServiceCacheDataSource;
@protocol QMChatConnectionDelegate;

typedef void(^QMCacheCollection)(NSArray *QB_NULLABLE_S collection);

/**
 *  QBChat connection state.
 */
typedef NS_ENUM(NSUInteger, QMChatConnectionState) {
    /**
     *  Not connected.
     */
    QMChatConnectionStateDisconnected,
    /**
     *  Connection in progress.
     */
    QMChatConnectionStateConnecting,
    /**
     *  Connected.
     */
    QMChatConnectionStateConnected
};

/**
 *  Chat dialog service
 */
@interface QMChatService : QMBaseService

/**
 *  Determines whether auto join for group dialogs is enabled or not.
 *  Default value is YES.
 *
 *  @discussion Disable auto join if you want to handle group chat dialogs joining manually
 *  or you are using our Enterprise feature to manage group chat dialogs without join being required.
 *  By default QMServices will perform join to all existent group dialogs in cache after
 *  every chat connect/reconnect and every chat dialog receive/update.
 */
@property (assign, nonatomic, getter=isAutoJoinEnabled) BOOL enableAutoJoin;

/**
 *  Chat messages per page with messages load methods
 */
@property (assign, nonatomic) NSUInteger chatMessagesPerPage;

/**
 *  Chat connection state
 */
@property (assign, nonatomic, readonly) QMChatConnectionState chatConnectionState;

/**
 *  Dialogs datasoruce
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMDialogsMemoryStorage *dialogsMemoryStorage;

/**
 *  Messages datasource
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMMessagesMemoryStorage *messagesMemoryStorage;

/**
 *  Attachment Service
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMChatAttachmentService *chatAttachmentService;

/**
 *  Init chat service
 *
 *  @param serviceManager   delegate confirmed QMServiceManagerProtocol protocol
 *  @param cacheDataSource  delegate confirmed QMChatServiceCacheDataSource
 *
 *  @return Return QMChatService instance
 */
- (QB_NULLABLE instancetype)initWithServiceManager:(QB_NONNULL id<QMServiceManagerProtocol>)serviceManager
                                   cacheDataSource:(QB_NULLABLE id<QMChatServiceCacheDataSource>)cacheDataSource;
/**
 *  Add delegate (Multicast)
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)addDelegate:(QB_NONNULL id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Remove delegate from observed list
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)removeDelegate:(QB_NONNULL id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Connect to chat
 *
 *  @param completion   The block which informs whether a chat did connect or not. nil if no errors.
 */
- (void)connectWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Disconnect from chat
 *
 *  @param completion   The block which informs whether a chat did disconnect or not. nil if no errors.
 */
- (void)disconnectWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Automatically send chat presences when logged in
 *  Default value: YES
 *  @warning *Deprecated in QMServices 0.3.8:*
 */
@property (nonatomic, assign) BOOL automaticallySendPresences DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.8.");

/**
 *  Default value: 45 seconds
 *  @warning *Deprecated in QMServices 0.3.8:*
 */
@property (nonatomic, assign) NSTimeInterval presenceTimerInterval DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.8.");

#pragma mark - Group dialog join

/**
 *  Joins user to group dialog and correctly updates cache. Please use this method instead of 'join' in QBChatDialog if you are using QMServices.
 *
 *  @param dialog       dialog to join
 *  @param completion   completion block with failure error
 */
- (void)joinToGroupDialog:(QB_NONNULL QBChatDialog *)dialog completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - Dialog history

/**
 *  Retrieve chat dialogs
 *
 *  @param extendedRequest Set of request parameters. http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters
 *  @param completion Block with response dialogs instances
 */
- (void)allDialogsWithPageLimit:(NSUInteger)limit
                extendedRequest:(QB_NULLABLE NSDictionary *)extendedRequest
                 iterationBlock:(void(^QB_NULLABLE_S )(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) *QB_NULLABLE_S dialogObjects, NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs, BOOL * QB_NONNULL_S stop))iterationBlock
                     completion:(void(^QB_NULLABLE_S)(QBResponse * QB_NONNULL_S response))completion;

#pragma mark - Chat dialog creation

/**
 *  Create p2p dialog
 *
 *  @param opponent   QBUUser opponent
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponent:(QB_NONNULL QBUUser *)opponent
                                 completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S createdDialog))completion;

/**
 *  Create group dialog
 *
 *  @param name       Dialog name
 *  @param occupants  QBUUser collection
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createGroupChatDialogWithName:(QB_NULLABLE NSString *)name photo:(QB_NULLABLE NSString *)photo occupants:(QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)occupants completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S createdDialog))completion;

/**
 *  Create p2p dialog
 *
 *  @param opponentID Opponent ID
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID
                                   completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S createdDialog))completion;

#pragma mark - Edit dialog methods

/**
 *  Change dialog name
 *
 *  @param dialogName Dialog name
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)changeDialogName:(QB_NONNULL NSString *)dialogName forChatDialog:(QB_NONNULL QBChatDialog *)chatDialog
              completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S updatedDialog))completion;

/**
 *  Change dialog avatar
 *
 *  @param avatarPublicUrl avatar url
 *  @param chatDialog      QBChatDialog instance
 *  @param completion      Block with response and updated chat dialog instances
 */
- (void)changeDialogAvatar:(QB_NONNULL NSString *)avatarPublicUrl forChatDialog:(QB_NONNULL QBChatDialog *)chatDialog
                completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S updatedDialog))completion;

/**
 *  Join occupants
 *
 *  @param ids        Occupants ids
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)joinOccupantsWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)ids toChatDialog:(QB_NONNULL QBChatDialog *)chatDialog
                  completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBChatDialog *QB_NULLABLE_S updatedDialog))completion;

/**
 *  Delete dialog by id on server and chat cache
 *
 *  @param completion Block with response dialogs instances
 */
- (void)deleteDialogWithID:(QB_NONNULL NSString *)dialogId
                completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response))completion;

/**
 *  Loads dialogs specific to user from disc cache and puth them in memory storage.
 *  @warning This method MUST be called after the login.
 *
 *  @param completion Completion block to handle ending of operation.
 */
- (void)loadCachedDialogsWithCompletion:(QB_NULLABLE dispatch_block_t)completion;

#pragma mark - System Messages

/**
 *  Send system message to users about adding to dialog with dialog inside.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param completion   completion block with failure error
 *
 *  @warning *Deprecated in QMServices 0.4.1:* Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:withText:completion' instead.
 */
- (void)sendSystemMessageAboutAddingToDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                  toUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)usersIDs
                                  completion:(QB_NULLABLE QBChatCompletionBlock)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.1. Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:withText:completion:' instead.");
/**
 *  Send system message to users about adding to dialog with dialog inside with text.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param text         text to users
 *  @param completion   completion block with failure error
 */
- (void)sendSystemMessageAboutAddingToDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                  toUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)usersIDs
                                    withText:(QB_NULLABLE NSString *)text
                                  completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - Notification messages

/**
 *  Send message about accepting or rejecting contact requst.
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponent   opponent ID
 *  @param completion completion block with failure error
 */
- (void)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                   toOpponentID:(NSUInteger)opponentID
                                     completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Sending notification message about adding occupants to specific dialog.
 *
 *  @param occupantsIDs     array of occupants that were added to a specific dialog
 *  @param chatDialog       chat dialog to send notification message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutAddingOccupants:(QB_NONNULL NSArray QB_GENERIC(NSNumber *)*)occupantsIDs
                                           toDialog:(QB_NONNULL QBChatDialog *)chatDialog
                               withNotificationText:(QB_NONNULL NSString *)notificationText
                                         completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Sending notification message about leaving dialog.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutLeavingDialog:(QB_NONNULL QBChatDialog *)chatDialog
                             withNotificationText:(QB_NONNULL NSString *)notificationText
                                       completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Sending notification message about changing dialog photo.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutChangingDialogPhoto:(QB_NONNULL QBChatDialog *)chatDialog
                                   withNotificationText:(QB_NONNULL NSString *)notificationText
                                             completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Sending notification message about changing dialog name.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutChangingDialogName:(QB_NONNULL QBChatDialog *)chatDialog
                                  withNotificationText:(QB_NONNULL NSString *)notificationText
                                            completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - Fetch messages

/**
 *  Deleting message from cache and memory storage.
 *
 *  @param message message to delete
 */
- (void)deleteMessageLocally:(QB_NONNULL QBChatMessage *)message;

/**
 *  Deleting messages from cache and memory storage.
 *
 *  @param messages messages to delete
 *  @param dialogID chat dialog identifier
 */
- (void)deleteMessagesLocally:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Fetch messages with chat dialog id.
 *
 *  @param chatDialogID Chat dialog id.
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed.
 */
- (void)messagesWithChatDialogID:(QB_NONNULL NSString *)chatDialogID completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBChatMessage *) *QB_NULLABLE_S messages))completion;

/**
 *  Loads messages that are older than oldest message in cache.
 *
 *  @param chatDialogID Chat dialog identifier
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed
 */
- (void)earlierMessagesWithChatDialogID:(QB_NONNULL NSString *)chatDialogID completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBChatMessage *) *QB_NULLABLE_S messages))completion;

#pragma mark - Fetch dialogs

/**
 *  Fetch dialog with dialog id.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)fetchDialogWithID:(QB_NONNULL NSString *)dialogID completion:(void (^QB_NULLABLE_S)(QBChatDialog *QB_NULLABLE_S dialog))completion;

/**
 *  Load dialog with dialog id from Quickblox and saving to memory storage and cache.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)loadDialogWithID:(QB_NONNULL NSString *)dialogID completion:(void (^QB_NULLABLE_S)(QBChatDialog *QB_NULLABLE_S loadedDialog))completion;

/**
 *  Fetch dialog with last activity date from date
 *
 *  @param date         date to fetch dialogs from
 *  @param limit        page limit
 *  @param iteration    iteration block with dialogs for pages
 *  @param completion   Block with response when fetching finished
 */
- (void)fetchDialogsUpdatedFromDate:(QB_NONNULL NSDate *)date
                       andPageLimit:(NSUInteger)limit
                     iterationBlock:(void(^QB_NULLABLE_S)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) *QB_NULLABLE_S dialogObjects, NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs, BOOL * QB_NONNULL_S stop))iteration
                    completionBlock:(void (^QB_NULLABLE_S)(QBResponse * QB_NONNULL_S response))completion;

#pragma mark Send message

/**
 *  Send message with a specific message type to dialog with identifier.
 *
 *  @param message       QBChatMessage instance
 *  @param type          QMMessageType type
 *  @param dialog        QBChatDialog instance
 *  @param saveToHistory if YES - saves message to chat history
 *  @param saveToStorage if YES - saves to local storage
 *  @param completion    completion block with failure error
 *
 *  @discussion The purpose of this method is to have a proper way of sending messages
 *  with a different message type, which does not have their own methods (e.g. contact request).
 */
- (void)sendMessage:(QB_NONNULL QBChatMessage *)message
               type:(QMMessageType)type
           toDialog:(QB_NONNULL QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send message to dialog with identifier.
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QB_NONNULL QBChatMessage *)message
         toDialogID:(QB_NONNULL NSString *)dialogID
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send message to.
 *
 *  @param message          QBChatMessage instance
 *  @param dialog           dialog instance to send message to
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QB_NONNULL QBChatMessage *)message
           toDialog:(QB_NONNULL QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send attachment message to dialog.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param image                attachment image to upload
 *  @param completion           completion block with failure error
 */
- (void)sendAttachmentMessage:(QB_NONNULL QBChatMessage *)attachmentMessage
                     toDialog:(QB_NONNULL QBChatDialog *)dialog
          withAttachmentImage:(QB_NONNULL UIImage *)image
                   completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - mark as delivered

/**
 *  Mark message as delivered.
 *
 *  @param message      QBChatMessage instance to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessageAsDelivered:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Mark messages as delivered.
 *
 *  @param message      array of QBChatMessage instances to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessagesAsDelivered:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - read messages

/**
 *  Sending read status for message and updating unreadMessageCount for dialog in cache
 *
 *  @param message      QBChatMessage instance to mark as read
 *  @param completion   completion block with failure error
 */
- (void)readMessage:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Sending read status for messages and updating unreadMessageCount for dialog in cache
 *
 *  @param messages     Array of QBChatMessage instances to mark as read
 *  @param dialogID     ID of dialog to update
 *  @param completion   completion block with failure error
 */
- (void)readMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

@end

#pragma mark - Bolts

/**
 *  Bolts methods for QMChatService
 */
@interface QMChatService (Bolts)

/**
 *  Connect to the chat using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)connect;

/**
 *  Disconnect from the chat using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)disconnect;

/**
 *  Join group chat dialog.
 *
 *  @param dialog group chat dialog to join
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)joinToGroupDialog:(QB_NONNULL QBChatDialog *)dialog;

/**
 *  Retrieve chat dialogs using Bolts.
 *
 *  @param extendedRequest Set of request parameters. http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters
 *  @param iterationBlock  block with dialog pagination
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)allDialogsWithPageLimit:(NSUInteger)limit
                               extendedRequest:(QB_NULLABLE NSDictionary *)extendedRequest
                                iterationBlock:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) * QB_NULLABLE_S dialogObjects, NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs, BOOL * QB_NONNULL_S stop))iterationBlock;

/**
 *  Create private dialog with user if needed using Bolts.
 *
 *  @param opponent opponent user to create private dialog with
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)createPrivateChatDialogWithOpponent:(QB_NONNULL QBUUser *)opponent;

/**
 *  Create group chat using Bolts.
 *
 *  @param name      group chat name
 *  @param photo     group chatm photo url
 *  @param occupants array of QBUUser instances to add to chat
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)createGroupChatDialogWithName:(QB_NULLABLE NSString *)name photo:(QB_NULLABLE NSString *)photo occupants:(QB_NONNULL NSArray QB_GENERIC(QBUUser *) *)occupants;

/**
 *  Create private dialog if needed using Bolts.
 *
 *  @param opponentID opponent user identificatior to create dialog with
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID;

/**
 *  Change dialog name using Bolts.
 *
 *  @param dialogName new dialog name
 *  @param chatDialog chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)changeDialogName:(QB_NONNULL NSString *)dialogName forChatDialog:(QB_NONNULL QBChatDialog *)chatDialog;

/**
 *  Change dialog avatar using Bolts.
 *
 *  @param avatarPublicUrl avatar url
 *  @param chatDialog      chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)changeDialogAvatar:(QB_NONNULL NSString *)avatarPublicUrl forChatDialog:(QB_NONNULL QBChatDialog *)chatDialog;

/**
 *  Join occupants to dialog using Bolts.
 *
 *  @param ids        occupants ids to join
 *  @param chatDialog chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)joinOccupantsWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)ids toChatDialog:(QB_NONNULL QBChatDialog *)chatDialog;

/**
 *  Delete dialog by id on server and chat cache using Bolts
 *
 *  @param dialogID id of dialog to delete
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)deleteDialogWithID:(QB_NONNULL NSString *)dialogID;

/**
 *  Fetch messages with chat dialog id using Bolts.
 *
 *  @param chatDialogID chat dialog identifier to fetch messages from
 *
 *  @return BFTask with NSArray of QBChatMessage instances
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(NSArray QB_GENERIC(QBChatMessage *) *) *)messagesWithChatDialogID:(QB_NONNULL NSString *)chatDialogID;

/**
 *  Loads messages that are older than oldest message in cache.
 *
 *  @param chatDialogID     chat dialog identifier
 *
 *  @return BFTask instance of QBChatMessage's array
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(NSArray QB_GENERIC(QBChatMessage *) *) *)loadEarlierMessagesWithChatDialogID:(QB_NONNULL NSString *)chatDialogID;

/**
 *  Fetch dialog with identifier using Bolts.
 *
 *  @param dialogID dialog identifier to fetch
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)fetchDialogWithID:(QB_NONNULL NSString *)dialogID;

/**
 *  Load dialog with dialog identifier from server and saving to memory storage and cache using Bolts.
 *
 *  @param dialogID dialog identifier to load.
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBChatDialog *) *)loadDialogWithID:(QB_NONNULL NSString *)dialogID;

/**
 *  Fetch dialog with last activity date from date using Bolts.
 *
 *  @param date         date to fetch dialogs from
 *  @param limit        page limit
 *  @param iteration    iteration block with dialogs for pages
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)fetchDialogsUpdatedFromDate:(QB_NONNULL NSDate *)date
                                      andPageLimit:(NSUInteger)limit
                                    iterationBlock:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBChatDialog *) * QB_NULLABLE_S dialogObjects, NSSet QB_GENERIC(NSNumber *) * QB_NULLABLE_S dialogsUsersIDs, BOOL * QB_NONNULL_S stop))iterationBlock;

/**
 *  Send system message to users about adding to dialog with dialog inside using Bolts.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *
 *  @warning *Deprecated in QMServices 0.4.1:* Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:withText:' instead.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendSystemMessageAboutAddingToDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                                 toUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)usersIDs  DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.1. Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:withText:' instead.");

/**
 *  Send system message to users about adding to dialog with dialog inside using Bolts.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param text         text to users
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendSystemMessageAboutAddingToDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                                 toUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)usersIDs
                                                   withText:(QB_NULLABLE NSString *)text;

/**
 *  Send message about accepting or rejecting contact requst using Bolts.
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponent   opponent ID
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                                  toOpponentID:(NSUInteger)opponentID;

/**
 *  Sending notification message about adding occupants to specific dialog using Bolts.
 *
 *  @param occupantsIDs     array of occupants that were added to a specific dialog
 *  @param chatDialog       chat dialog to send notification message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendNotificationMessageAboutAddingOccupants:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)occupantsIDs
                                                          toDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                              withNotificationText:(QB_NONNULL NSString *)notificationText;

/**
 *  Sending notification message about leaving dialog using Bolts.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendNotificationMessageAboutLeavingDialog:(QB_NONNULL QBChatDialog *)chatDialog
                                            withNotificationText:(QB_NONNULL NSString *)notificationText;

/**
 *  Sending notification message about changing dialog photo using Bolts.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendNotificationMessageAboutChangingDialogPhoto:(QB_NONNULL QBChatDialog *)chatDialog
                                                  withNotificationText:(QB_NONNULL NSString *)notificationText;

/**
 *  Sending notification message about changing dialog name.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendNotificationMessageAboutChangingDialogName:(QB_NONNULL QBChatDialog *)chatDialog
                                                 withNotificationText:(QB_NONNULL NSString *)notificationText;

/**
 *  Send message with a specific message type to dialog with identifier using Bolts.
 *
 *  @param message       QBChatMessage instance
 *  @param type          QMMessageType type
 *  @param dialog        QBChatDialog instance
 *  @param saveToHistory if YES - saves message to chat history
 *  @param saveToStorage if YES - saves to local storage
 *  @param completion    completion block with failure error
 *
 *  @discussion The purpose of this method is to have a proper way of sending messages
 *  with a different message type, which does not have their own methods (e.g. contact request).
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendMessage:(QB_NONNULL QBChatMessage *)message
                              type:(QMMessageType)type
                          toDialog:(QB_NONNULL QBChatDialog *)dialog
                     saveToHistory:(BOOL)saveToHistory
                     saveToStorage:(BOOL)saveToStorage;

/**
 *  Send message to dialog with identifier using Bolts.
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendMessage:(QB_NONNULL QBChatMessage *)message
                        toDialogID:(QB_NONNULL NSString *)dialogID
                     saveToHistory:(BOOL)saveToHistory
                     saveToStorage:(BOOL)saveToStorage;

/**
 *  Send message to using Bolts.
 *
 *  @param message          QBChatMessage instance
 *  @param dialog           dialog instance to send message to
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendMessage:(QB_NONNULL QBChatMessage *)message
                          toDialog:(QB_NONNULL QBChatDialog *)dialog
                     saveToHistory:(BOOL)saveToHistory
                     saveToStorage:(BOOL)saveToStorage;

/**
 *  Send attachment message to dialog using Bolts.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param image                attachment image to upload
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)sendAttachmentMessage:(QB_NONNULL QBChatMessage *)attachmentMessage
                                    toDialog:(QB_NONNULL QBChatDialog *)dialog
                         withAttachmentImage:(QB_NONNULL UIImage *)image;

/**
 *  Mark message as delivered.
 *
 *  @param message      QBChatMessage instance to mark as delivered
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)markMessageAsDelivered:(QB_NONNULL QBChatMessage *)message;

/**
 *  Mark messages as delivered.
 *
 *  @param message      array of QBChatMessage instances to mark as delivered
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)markMessagesAsDelivered:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages;

/**
 *  Sending read status for message and updating unreadMessageCount for dialog in cache
 *
 *  @param message      QBChatMessage instance to mark as read
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)readMessage:(QB_NONNULL QBChatMessage *)message;

/**
 *  Sending read status for messages and updating unreadMessageCount for dialog in cache
 *
 *  @param messages     Array of QBChatMessage instances to mark as read
 *  @param dialogID     ID of dialog to update
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)readMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

@end

@protocol QMChatServiceCacheDataSource <NSObject>
@required

/**
 * Is called when chat service will start. Need to use for inserting initial data QMDialogsMemoryStorage
 *
 *  @param block Block for provide QBChatDialogs collection
 */
- (void)cachedDialogs:(QB_NULLABLE QMCacheCollection)block;

/**
 *  Will return dialog with specific identificator from cache or nil if dialog doesn't exist
 *
 *  @param dialogID   dialog identificator
 *  @param complition completion block with dialog
 */
- (void)cachedDialogWithID:(QB_NONNULL NSString *)dialogID completion:(void (^QB_NULLABLE_S)(QBChatDialog *QB_NULLABLE_S dialog))completion;

/**
 *  Is called when begin fetch messages. @see -messagesWithChatDialogID:completion:
 *  Need to use for inserting initial data QMMessagesMemoryStorage by dialogID
 *
 *  @param dialogID Dialog ID
 *  @param block    Block for provide QBChatMessages collection
 */
- (void)cachedMessagesWithDialogID:(QB_NONNULL NSString *)dialogID block:(QB_NULLABLE QMCacheCollection)block;

@end

@protocol QMChatServiceDelegate <NSObject>
@optional

/**
 *  Is called when ChatDialogs did load from cache.
 *
 *  @param chatService      instance
 *  @param dialogs          array of QBChatDialogs loaded from cache
 *  @param dialogsUsersIDs  all users from all ChatDialogs
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didLoadChatDialogsFromCache:(QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogs withUsers:(QB_NONNULL NSSet QB_GENERIC(NSNumber *) *)dialogsUsersIDs;

/**
 *  Is called when messages did load from cache for some dialog.
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessages loaded from cache
 *  @param dialogID messages dialog ID
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didLoadMessagesFromCache:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when dialog instance did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialog QBChatDialog has added to memory storage
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didAddChatDialogToMemoryStorage:(QB_NONNULL QBChatDialog *)chatDialog;

/**
 *  Is called when dialogs array did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialogs QBChatDialog items has added to memory storage
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didAddChatDialogsToMemoryStorage:(QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)chatDialogs;

/**
 *  Is called when some dialog did update in memory storage
 *
 *  @param chatService instance
 *  @param chatDialog updated QBChatDialog
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QB_NONNULL QBChatDialog *)chatDialog;

/**
 *  Is called when some dialogs did update in memory storage
 *
 *  @param chatService instance
 *  @param dialogs     updated array of QBChatDialog's
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogs;

/**
 *  Is called when some dialog did delete from memory storage
 *
 *  @param chatService instance
 *  @param chatDialog deleted QBChatDialog
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(QB_NONNULL NSString *)chatDialogID;

/**
 *  Is called when message did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message added QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didAddMessageToMemoryStorage:(QB_NONNULL QBChatMessage *)message forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when message did update in memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message updated QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didUpdateMessage:(QB_NONNULL QBChatMessage *)message forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when message did update in memory storage for dialog with id
 *
 *  @param chatService  instance
 *  @param messages     array of updated messages
 *  @param dialogID     messages dialog ID
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didUpdateMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when messages did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didAddMessagesToMemoryStorage:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *)*)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when message was deleted from memory storage for dialog id
 *
 *  @param chatService chat service instance
 *  @param message     message that was deleted
 *  @param dialogID    dialog identifier of deleted message
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didDeleteMessageFromMemoryStorage:(QB_NONNULL QBChatMessage *)message forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when messages was deleted from memory storage for dialog id
 *
 *  @param chatService chat service instance
 *  @param messages    messages that were deleted
 *  @param dialogID    dialog identifier of deleted messages
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didDeleteMessagesFromMemoryStorage:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *)*)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is called when chat service did receive notification message
 *
 *  @param chatService instance
 *  @param message received notification message
 *  @param dialog QBChatDialog from notification message
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService didReceiveNotificationMessage:(QB_NONNULL QBChatMessage *)message createDialog:(QB_NONNULL QBChatDialog *)dialog;

@end

/**
 *  Chat connection delegate can handle chat stream events. Like did connect, did reconnect etc...
 */

@protocol QMChatConnectionDelegate <NSObject>
@optional

/**
 *  Called when chat service did start connecting to the chat.
 *
 *  @param chatService QMChatService instance
 */
- (void)chatServiceChatHasStartedConnecting:(QB_NONNULL QMChatService *)chatService;

/**
 *  It called when chat did connect.
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidConnect:(QB_NONNULL QMChatService *)chatService;

/**
 *  Called when chat did not connect.
 *
 *  @param chatService instance
 *  @param error       connection failure error
 */
- (void)chatService:(QB_NONNULL QMChatService *)chatService chatDidNotConnectWithError:(QB_NONNULL NSError *)error;

/**
 *  It called when chat did accidentally disconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidAccidentallyDisconnect:(QB_NONNULL QMChatService *)chatService;

/**
 *  It called when chat did reconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidReconnect:(QB_NONNULL QMChatService *)chatService;

/**
 *  It called when chat did catch error from chat stream
 *
 *  @param error NSError from stream
 */
- (void)chatServiceChatDidFailWithStreamError:(QB_NONNULL NSError *)error;

@end
