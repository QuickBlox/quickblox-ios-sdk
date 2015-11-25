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

typedef void(^QMCacheCollection)(NSArray *collection);

/**
 *  Chat dialog service
 */
@interface QMChatService : QMBaseService

/**
 *  Chat messages per page with messages load methods
 */
@property (assign, nonatomic) NSUInteger chatMessagesPerPage;

/**
 *  Dialogs datasoruce
 */
@property (strong, nonatomic, readonly) QMDialogsMemoryStorage *dialogsMemoryStorage;

/**
 *  Messages datasource
 */
@property (strong, nonatomic, readonly) QMMessagesMemoryStorage *messagesMemoryStorage;

/**
 *  Attachment Service
 */
@property (strong, nonatomic, readonly) QMChatAttachmentService *chatAttachmentService;

/**
 *  Init chat service
 *
 *  @param serviceManager   delegate confirmed QMServiceManagerProtocol protocol
 *  @param cacheDataSource  delegate confirmed QMChatServiceCacheDataSource
 *
 *  @return Return QMChatService instance
 */
- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMChatServiceCacheDataSource>)cacheDataSource;
/**
 *  Add delegate (Multicast)
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)addDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Remove delegate from observed list
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)removeDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Login to chat
 *
 *  @param completion The block which informs whether a chat did login or not. nil if no errors.
 *
 *  @warning *Deprecated in QMServices 0.3:* Use 'connectWithCompletionBlock:' instead.
 */
- (void)logIn:(QBChatCompletionBlock)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3. Use 'connectWithCompletionBlock:' instead.");

/**
 *  Connect to chat
 *
 *  @param completion   The block which informs whether a chat did connect or not. nil if no errors.
 */
- (void)connectWithCompletionBlock:(QBChatCompletionBlock)completion;

/**
 *  Logout from chat
 *
 *  @warning *Deprecated in QMServices 0.3:* Use 'disconnectWithCompletionBlock:' instead.
 */
- (void)logoutChat DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3. Use 'disconnectWithCompletionBlock:' instead.");

/**
 *  Disconnect from chat
 *
 *  @param completion   The block which informs whether a chat did disconnect or not. nil if no errors.
 */
- (void)disconnectWithCompletionBlock:(QBChatCompletionBlock)completion;

/**
 *  Automatically send chat presences when logged in
 *  Default value: YES
 */
@property (nonatomic, assign) BOOL automaticallySendPresences;

/**
 *  Default value: 45 seconds
 */
@property (nonatomic, assign) NSTimeInterval presenceTimerInterval;

/**
 *  Joins user to group dialog and correctly updates cache. Please use this method instead of 'join' in QBChatDialog if you are using QMServices.
 *
 *  @param dialog Dialog to join.
 *  @param failed Failed callback.
 *
 *  @warning *Deprecated in QMServices 0.3:* Use 'joinToGroupDialog:completion:' instead.
 */
- (void)joinToGroupDialog:(QBChatDialog *)dialog
                   failed:(void(^)(NSError *error))failed DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3. Use 'joinToGroupDialog:completion:' instead.");

/**
 *  Joins user to group dialog and correctly updates cache. Please use this method instead of 'join' in QBChatDialog if you are using QMServices.
 *
 *  @param dialog       dialog to join
 *  @param completion   completion block with failure error
 */
- (void)joinToGroupDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion;

/**
 *  Create group dialog
 *
 *  @param name       Dialog name
 *  @param occupants  QBUUser collection
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createGroupChatDialogWithName:(NSString *)name photo:(NSString *)photo occupants:(NSArray *)occupants
                           completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion;
/**
 *  Create p2p dialog
 *
 *  @param opponent   QBUUser opponent
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent
                                 completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion;

/**
 *  Create p2p dialog
 *
 *  @param opponentID Opponent ID
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID
                                   completion:(void(^)(QBResponse *response, QBChatDialog *createdDialo))completion;

/**
 *  Change dialog name
 *
 *  @param dialogName Dialog name
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog
              completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;

/**
 *  Change dialog avatar
 *
 *  @param avatarPublicUrl avatar url
 *  @param chatDialog      QBChatDialog instance
 *  @param completion      Block with response and updated chat dialog instances
 */
- (void)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog
                completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;

/**
 *  Join occupants
 *
 *  @param ids        Occupants ids
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)joinOccupantsWithIDs:(NSArray *)ids toChatDialog:(QBChatDialog *)chatDialog
                  completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;

/**
 *  Delete dialog by id on server and chat cache
 *
 *  @param completion Block with response dialogs instances
 */
- (void)deleteDialogWithID:(NSString *)dialogId
                completion:(void(^)(QBResponse *response))completion;

/**
 *  Retrieve chat dialogs
 *
 *  @param extendedRequest Set of request parameters. http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters
 *  @param completion Block with response dialogs instances
 */
- (void)allDialogsWithPageLimit:(NSUInteger)limit
                extendedRequest:(NSDictionary *)extendedRequest
                iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))interationBlock
                     completion:(void(^)(QBResponse *response))completion;

/**
 *  Loads dialogs specific to user from disc cache and puth them in memory storage. 
 *  @warning This method MUST be called after the login.
 *
 *  @param completion Completion block to handle ending of operation.
 */
- (void)loadCachedDialogsWithCompletion:(void(^)())completion;

#pragma mark - System Messages

/**
 *  Notify opponents about creating the dialog
 *
 *  @param dialog       created dialog we notificate about
 *  @param usersIDs     [NSNumber] array of OccupantIDs which not be notified
 *  @param completion   completion block with failure error
 *
 *  @warning *Deprecated in QMServices 0.3.1:* Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:completion:' instead.
 */
- (void)notifyUsersWithIDs:(NSArray *)usersIDs aboutAddingToDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.1. Use 'sendSystemMessageAboutAddingToDialog:toUsersIDs:completion:' instead.");;

/**
 *  Send system message to users about adding to dialog with dialog inside.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param completion   completion block with failure error
 */
- (void)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                  toUsersIDs:(NSArray *)usersIDs
                                  completion:(QBChatCompletionBlock)completion;

/**
 *  Notify opponents about update the dialog
 *
 *  @param updatedDialog                updated dialog
 *  @param occupantsCustomParameters    {NSNumber : NSDictionary} dictionary of custom parameters for each occupant
 *  @param notificationText             notification text
 *  @param completion                   completion block with failure error
 *
 *  @warning *Deprecated in QMServices 0.3.1:* Use 'sendMessageAboutUpdateDialog:withNotificationText:customParameters:completion:' instead.
 */
- (void)notifyAboutUpdateDialog:(QBChatDialog *)updatedDialog
      occupantsCustomParameters:(NSDictionary *)occupantsCustomParameters
               notificationText:(NSString *)notificationText
                     completion:(QBChatCompletionBlock)completion
        DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.1. Use 'sendMessageAboutUpdateDialog:withNotificationText:customParameters:completion:' instead.");

/**
 *  Send message about updated dialog with dialog inside and notification.
 *
 *  @param updatedDialog        updated dialog
 *  @param notificationText     notification text
 *  @param customParameters     {NSNumber : NSDictionary} dictionary of custom parameters
 *  @param completion           completion block with failure error
 */
- (void)sendMessageAboutUpdateDialog:(QBChatDialog *)updatedDialog
                withNotificationText:(NSString *)notificationText
                    customParameters:(NSDictionary *)customParameters
                          completion:(QBChatCompletionBlock)completion;

/**
 *  Notify opponent about accept or reject contact request
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponent   opponent ID
 *  @param completion completion block with failure error
 *
 *  @warning *Deprecated in QMServices 0.3.1:* Use 'sendMessageAboutAcceptingContactRequest:toOpponentID:completion:' instead.
 */
- (void)notifyOponentAboutAcceptingContactRequest:(BOOL)accept
                                       opponentID:(NSUInteger)opponentID
                                       completion:(QBChatCompletionBlock)completion
                          DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.1. Use 'sendMessageAboutAcceptingContactRequest:toOpponentID:completion:' instead.");

/**
 *  Send message about accepting or rejecting contact requst.
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponent   opponent ID
 *  @param completion completion block with failure error
 */
- (void)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                   toOpponentID:(NSUInteger)opponentID
                                     completion:(QBChatCompletionBlock)completion;

#pragma mark - Fetch messages

/**
 *  Fetch messages with chat dialog id.
 *
 *  @param chatDialogID Chat dialog id.
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed.
 */

- (void)messagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion;

/**
 *  Loads 100 messages that are older than oldest message in cache.
 *
 *  @param chatDialogID     chat dialog identifier
 *
 *  @return BFTask instance of QBChatMessage's array
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBChatMessage *) *) *)loadEarlierMessagesWithChatDialogID:(NSString *)chatDialogID;

/**
 *  Loads 100 messages that are older than oldest message in cache.
 *
 *  @param chatDialogID Chat dialog identifier
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed
 *
 *  @warning *Deprecated in QMServices 0.3.1:* Use 'loadEarlierMessagesWithChatDialogID:' instead.
 */
- (void)earlierMessagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.1. Use 'loadEarlierMessagesWithChatDialogID:' instead.");;

#pragma mark - Fetch dialogs

/**
 *  Fetch dialog with dialog id.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion;

/**
 *  Load dialog with dialog id from Quickblox and saving to memory storage and cache.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)loadDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *loadedDialog))completion;

/**
 *  Fetch dialog with last activity date from date
 *
 *  @param date         date to fetch dialogs from
 *  @param limit        page limit
 *  @param iteration    iteration block with dialogs for pages
 *  @param completion   Block with response when fetching finished
 */
- (void)fetchDialogsUpdatedFromDate:(NSDate *)date andPageLimit:(NSUInteger)limit iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iteration completionBlock:(void (^)(QBResponse *response))completion;

#pragma mark Send message

/**
 *  Send message to dialog with identifier
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QBChatMessage *)message
         toDialogID:(NSString *)dialogID
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion;

/**
 *  Send message to dialog with identifier
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion;

#pragma mark - mark as delivered

/**
 *  Mark message as delivered.
 * 
 *  @param message      QBChatMessage instance to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessageAsDelivered:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion;

/**
 *  Mark messages as delivered.
 *
 *  @param message      array of QBChatMessage instances to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessagesAsDelivered:(NSArray QB_GENERIC(QBChatMessage *) *)messages completion:(QBChatCompletionBlock)completion;

#pragma mark - read messages

/**
 *  Sending read status for message and updating unreadMessageCount for dialog in cache
 *
 *  @param message      QBChatMessage instance to mark as read
 *  @param completion   completion block with failure error
 */
- (void)readMessage:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion;

/**
 *  Sending read status for messages and updating unreadMessageCount for dialog in cache
 *
 *  @param messages     Array of QBChatMessage instances to mark as read
 *  @param dialogID     ID of dialog to update
 *  @param completion   completion block with failure error
 */
- (void)readMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(NSString *)dialogID completion:(QBChatCompletionBlock)completion;

@end

@protocol QMChatServiceCacheDataSource <NSObject>
@required
 
/**
 * Is called when chat service will start. Need to use for inserting initial data QMDialogsMemoryStorage
 *
 *  @param block Block for provide QBChatDialogs collection
 */
- (void)cachedDialogs:(QMCacheCollection)block;

/**
 *  Will retrieve dialog with specific identificator from cache or nil if doesnt exists
 *  
 *  @param dialogID   dialog identificator
 *  @param complition completion block with dialog
 */
- (void)cachedDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion;

/**
 *  Is called when begin fetch messages. @see -messagesWithChatDialogID:completion:
 *  Need to use for inserting initial data QMMessagesMemoryStorage by dialogID
 *
 *  @param dialogID Dialog ID
 *  @param block    Block for provide QBChatMessages collection
 */
- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block;

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
- (void)chatService:(QMChatService *)chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)dialogsUsersIDs;

/**
 *  Is called when messages did load from cache for some dialog.
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessages loaded from cache
 *  @param dialogID messages dialog ID
 */
- (void)chatService:(QMChatService *)chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when dialog instance did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialog QBChatDialog has added to memory storage
 */
- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog;

/**
 *  Is called when dialogs array did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialogs QBChatDialog items has added to memory storage
 */
- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs;

/**
 *  Is called when some dialog did update in memory storage
 *
 *  @param chatService instance
 *  @param chatDialog updated QBChatDialog
 */
- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog;

/**
 *  Is called when some dialog did delete from memory storage
 *
 *  @param chatService instance
 *  @param chatDialog deleted QBChatDialog
 */
- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID;

/**
 *  Is called when message did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message added QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Is called when message did update in memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message updated QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Is called when messages did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when chat service did receive notification message
 *
 *  @param chatService instance
 *  @param message received notification message
 *  @param dialog QBChatDialog from notification message
 */
- (void)chatService:(QMChatService *)chatService  didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog;



@end

/**
 *  Chat connection delegate can handle chat stream events. Like did connect, did reconnect etc...
 */

@protocol QMChatConnectionDelegate <NSObject>
@optional

/**
 *  It called when chat did connect.
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidConnect:(QMChatService *)chatService;

/**
 *  It called when user did login in chat.
 */
- (void)chatServiceChatDidLogin;

/**
 *  It called when user login failed.
 *
 *  @param error NSError login fail reason
 */
- (void)chatServiceChatDidNotLoginWithError:(NSError *)error;

/**
 *  It called when chat did accidentally disconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService;

/**
 *  It called when chat did reconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidReconnect:(QMChatService *)chatService;

/**
 *  It called when chat did catch error from chat stream
 *
 *  @param error NSError from stream
 */
- (void)chatServiceChatDidFailWithStreamError:(NSError *)error;

@end

