//
//  QMChatCache.h
//  QMServices
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMDBStorage.h"

NS_ASSUME_NONNULL_BEGIN
@interface QMChatCache : QMDBStorage

/**
 *  Messages limit in storage per dialog
 */
@property (nonatomic, assign) NSUInteger messagesLimitPerDialog; // default - NSNotFound (infinity)

//MARK: - Singleton

/**
 *  Chat cache singleton
 *
 *  @return QMChatCache instance
 */

@property (nonatomic, readonly, class) QMChatCache *instance;

//MARK: - Configure store

/**
 *  Setup QMChatCache stack with store name
 *
 *  @param storeName Store name
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName;
/**
 *  Clean clean chat cache with store name
 *
 *  @param name Store name
 */
+ (void)cleanDBWithStoreName:(NSString *)name;

//MARK: - Dialogs
//MARK: - Insert / Update / Delete dialog operations

/**
 *  Insert/Update dialog in cache
 *
 *  @param dialog QBChatDialog instance
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateDialog:(QBChatDialog *)dialog
                  completion:(nullable dispatch_block_t)completion;

/**
 *  Insert/Update dialogs
 *
 *  @param dialogs    Array of QBChatDialog instances
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateDialogs:(NSArray<QBChatDialog *> *)dialogs
                   completion:(nullable dispatch_block_t)completion;

/**
 *  Delete dialog from cache
 *
 *  @param dialogID Dialog Identifier
 *  @param completion Completion block is called after delete operation is completed
 */
- (void)deleteDialogWithID:(NSString *)dialogID
                completion:(nullable dispatch_block_t)completion;

/**
 *  Delete all dialogs
 *
 *  @param completion Completion block is called after delete all dialogs operation is completed
 */
- (void)deleteAllDialogsWithCompletion:(nullable dispatch_block_t)completion;

//MARK: Fetch dialog operations

/**
 Dialog by specific ID

 @param dialogID QBChatDialog identificator
 @return Returns requested dialog or nil if not found
 */
- (nullable QBChatDialog *)dialogByID:(NSString *)dialogID;

/**
 Fetch All Dialogs (Fetch in Main Queue context)

 @return Returns an array of QBChatDialog instances
 */
- (NSArray<QBChatDialog *> *)allDialogs;

/**
 Fetch Dialogs
 
    Key for filtering:
    id
	lastMessageDate
	lastMessageText
	lastMessageUserID
	name;
	occupantsIDs
	ocupantsIDs
	photo
	recipientID
	roomJID
	type
	unreadMessagesCount
	userID

 @param sortTerm Attribute name to sort by.
 @param ascending `YES` if the attribute should be sorted ascending, `NO` for descending.
 @param predicate Predicate to evaluate objects against
 @return Returns an array of QBChatDialog instances
 */
- (NSArray<QBChatDialog *> *)dialogsSortedBy:(NSString *)sortTerm
                                   ascending:(BOOL)ascending
                               withPredicate:(nullable NSPredicate *)predicate;

/**
 Dialog by specific ID

 @param dialogID QBChatDialog identifier
 @param completion Returns requested dialog or nil if not found
 */
- (void)dialogByID:(NSString *)dialogID
        completion:(void (^)(QBChatDialog *dialog))completion;

/**
 Fetch All Dialogs (Fetch in Private Queue context)

 @param completion Returns an array of QBChatDialog instances
 */
- (void)allDialogsWithCompletion:(nullable void(^)(NSArray<QBChatDialog *> * _Nullable dialogs))completion;
/**
 *   Asynchronous fetches all cached dialogs
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBChatDialog instances
 */
- (void)dialogsSortedBy:(NSString *)sortTerm
              ascending:(BOOL)ascending
             completion:(nullable void(^)(NSArray<QBChatDialog *> * _Nullable dialogs))completion;
/**
 *  Fetch cached dialogs with predicate
 *
 *  Key for filtering:
 *  id
	lastMessageDate
	lastMessageText
	lastMessageUserID
	name;
	occupantsIDs
	ocupantsIDs
	photo
	recipientID
	roomJID
	type
	unreadMessagesCount
	userID
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param predicate  Predicate to evaluate objects against
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBChatDialog instances
 */
- (void)dialogsSortedBy:(NSString *)sortTerm
              ascending:(BOOL)ascending
          withPredicate:(nullable NSPredicate *)predicate
             completion:(nullable void(^)(NSArray<QBChatDialog *> * _Nullable dialogs))completion;

//MARK: - Messages
//MARK: -

/**
 *  Asynchronous insert or update message in to persistent store
 *
 *  @param message    QBChatMessage instance
 *  @param dialogID   Dialog identifier
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateMessage:(QBChatMessage *)message
                 withDialogId:(NSString *)dialogID
                   completion:(nullable dispatch_block_t)completion;

/**
 *  Asynchronous insert or update messages in to persistent store
 *
 *  @param messages   Array of QBChatMessage instances
 *  @param dialogID   Dialog identifier
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateMessages:(NSArray<QBChatMessage *> *)messages
                  withDialogId:(NSString *)dialogID
                    completion:(nullable dispatch_block_t)completion;

/**
 *  Asynchronously deletes message
 *
 *  @param message    QBChatMessage instance
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessage:(QBChatMessage *)message
           completion:(nullable dispatch_block_t)completion;

/**
 Asynchronously deletes messages
 
 @param messages   messages to delete
 @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessages:(NSArray<QBChatMessage *> *)messages
            completion:(nullable dispatch_block_t)completion;

/**
 Asynchronously deletes messages for dialog ID
 
 @param dialogID   dialog identifier
 @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessageWithDialogID:(NSString *)dialogID
                       completion:(nullable dispatch_block_t)completion;

/**
 Asynchronously deletes all messages
 
 @param completion Completion block that is called after the delete all messages operation  has completed.
 */
- (void)deleteAllMessagesWithCompletion:(nullable dispatch_block_t)completion;

//MARK: Fetch Messages operations

/**
 Synchronously fetches cached messages with dialog id and filtering with predicate
 @param dialogId Dialog identifier
 @param sortTerm Attribute name to sort by.
 @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 @return returns an array of QBChatMessages instances
 */
- (NSArray<QBChatMessage *> *)messagesWithDialogId:(NSString *)dialogId
                                          sortedBy:(NSString *)sortTerm
                                         ascending:(BOOL)ascending;

/**
 Asynchronously fetches cached messages with dialog id and filtering with predicate
 
 @param dialogId  Dialog identifier
 @param sortTerm  Attribute name to sort by.
 @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 @param completion returns an array of QBChatMessages instances
 */
- (void)messagesWithDialogId:(NSString *)dialogId
                    sortedBy:(NSString *)sortTerm
                   ascending:(BOOL)ascending
                  completion:(void(^)(NSArray<QBChatMessage *> *messages))completion;
/**
 Asynchronously fetches messages filtering with predicate
 
 @param predicate  Predicate to evaluate objects against
 @param sortTerm   Attribute name to sort by.
 @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 @param completion Completion block that is called after the fetch has completed. Returns an array of QBChatMessage instances
 */
- (void)messagesWithPredicate:(NSPredicate *)predicate
                     sortedBy:(NSString *)sortTerm
                    ascending:(BOOL)ascending
                   completion:(void(^)(NSArray<QBChatMessage *> *messages))completion;

- (void)truncateAll:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
