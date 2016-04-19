//
//  QMChatCache.h
//  QMServices
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMDBStorage.h"

@interface QMChatCache : QMDBStorage

/**
 *  Messages limit in storage per dialog
 */

@property (nonatomic, assign) NSUInteger messagesLimitPerDialog; // default - NSNotFound (infinity)

#pragma mark - Singleton

/**
 *  Chat cache singleton
 *
 *  @return QMChatCache instance
 */
+ (QB_NULLABLE QMChatCache *)instance;

#pragma mark - Configure store

/**
 *  Setup QMChatCache stack with store name
 *
 *  @param storeName Store name
 */
+ (void)setupDBWithStoreNamed:(QB_NONNULL NSString *)storeName;

/**
 *  Clean clean chat cache with store name
 *
 *  @param name Store name
 */
+ (void)cleanDBWithStoreName:(QB_NONNULL NSString *)name;

#pragma mark -
#pragma mark Dialogs
#pragma mark -
#pragma mark Insert / Update / Delete dialog operations

/**
 *  Insert/Update dialog in cache
 *
 *  @param dialog QBChatDialog instance
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateDialog:(QB_NONNULL QBChatDialog *)dialog completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Insert/Update dialogs
 *
 *  @param dialogs    Array of QBChatDialog instances
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateDialogs:(QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogs completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete dialog from cache
 *
 *  @param dialog
 *  @param completion Completion block is called after delete operation is completed
 */
- (void)deleteDialogWithID:(QB_NONNULL NSString *)dialog completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete all dialogs
 *
 *  @param completion Completion block is called after delete all dialogs operation is completed
 */
- (void)deleteAllDialogsWithCompletion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete all dialogs
 *
 *  @param completion Completion block is called after delete all dialogs operation is completed
 *  @warning *Deprecated in 0.3.8:* Use 'deleteAllDialogsWithCompletion:' instead.
 */
- (void)deleteAllDialogs:(QB_NULLABLE dispatch_block_t)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.8. Use 'deleteAllDialogsWithCompletion:' instead.");

#pragma mark Fetch dialog operations

/**
 *   Fetch all cached dialogs
 *
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBChatDialog instances
 */
- (void)dialogsSortedBy:(QB_NONNULL NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^QB_NULLABLE_S)(NSArray QB_GENERIC(QBChatDialog *) *QB_NULLABLE_S dialogs))completion;

/**
 *  Fetch dialog by specific ID
 *
 *  @param dialogID   dialog identificator
 *  @param completion Completion block that is called after the fetch has completed. Returns requested dialog or nil if not found
 */
- (void)dialogByID:(QB_NONNULL NSString *)dialogID completion:(void(^QB_NULLABLE_S)(QBChatDialog *QB_NULLABLE_S cachedDialog))completion;

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
- (void)dialogsSortedBy:(QB_NONNULL NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(QB_NULLABLE NSPredicate *)predicate completion:(void(^QB_NULLABLE_S)(NSArray QB_GENERIC(QBChatDialog *) *QB_NULLABLE_S dialogs))completion;

#pragma mark -
#pragma mark  Messages
#pragma mark -

/**
 *  Add message to cache
 *
 *  @param message    QBChatMessage instance
 *  @param dialogId   Dialog identifier
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateMessage:(QB_NONNULL QBChatMessage *)message withDialogId:(QB_NONNULL NSString *)dialogID completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Add message to cache
 *
 *  @param message    QBChatMessage instance
 *  @param dialogId   Dialog identifier
 *  @param isRead     mark read
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateMessage:(QB_NONNULL QBChatMessage *)message withDialogId:(QB_NONNULL NSString *)dialogID read:(BOOL)isRead completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Update or insert messages
 *
 *  @param messages   Array of QBChatMessage instances
 *  @param dialogID   Dialog identifier
 *  @param completion Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages withDialogId:(QB_NONNULL NSString *)dialogID completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete message
 *
 *  @param message    QBChatMessage instance
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessage:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete messages
 *
 *  @param messages   messages to delete
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete messages for dialog ID
 *
 *  @param dialogID   dialog identifier
 *  @param completion Completion block that is called after the delete operation has completed.
 */
- (void)deleteMessageWithDialogID:(QB_NONNULL NSString *)dialogID completion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete all messages
 *
 *  @param completion Completion block that is called after the delete all messages operation  has completed.
 */
- (void)deleteAllMessagesWithCompletion:(QB_NULLABLE dispatch_block_t)completion;

/**
 *  Delete all messages
 *
 *  @param completion Completion block that is called after the delete all messages operation  has completed.
 *  @warning *Deprecated in 0.3.8:* Use 'deleteAllMessagesWithCompletion:' instead.
 */
- (void)deleteAllMessages:(QB_NULLABLE dispatch_block_t)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.8:* Use 'deleteAllMessagesWithCompletion:' instead.");


#pragma mark Fetch Messages operations

/**
 *  Fetch cached messages with dialog id and filtering with predicate
 *
 *  @param dialogId   Dialog identifier
 *  @param predicate  Predicate to evaluate objects against
 *  @param completion returns an array of QBChatMessages instances
 */

- (void)messagesWithDialogId:(QB_NONNULL NSString *)dialogId sortedBy:(QB_NONNULL NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^QB_NULLABLE_S)(NSArray QB_GENERIC(QBChatMessage *) *QB_NULLABLE_S messages))completion;

/**
 *  Fetch messages
 *
 *  @param predicate  Predicate to evaluate objects against
 *  @param sortTerm   Attribute name to sort by.
 *  @param ascending  `YES` if the attribute should be sorted ascending, `NO` for descending.
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBChatMessage instances
 */
- (void)messagesWithPredicate:(QB_NONNULL NSPredicate *)predicate sortedBy:(QB_NONNULL NSString *)sortTerm ascending:(BOOL)ascending completion:(void(^QB_NULLABLE_S)(NSArray QB_GENERIC(QBChatMessage *) *QB_NULLABLE_S messages))completion;

@end
