//
//  QMMessagesMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 28.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

@interface QMMessagesMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 *  Add message to memory storage
 *
 *  @param message  QBChatMessage instnace
 *  @param dialogID Chat dialog identifier
 */
- (void)addMessage:(QB_NONNULL QBChatMessage *)message forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Add messages to memory storage
 *
 *  @param messages Array of QBChatMessage items
 *  @param dialogID Chat dialog identifier
 */
- (void)addMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Replace messages in memory storage for dialog identifier
 *
 *  @param messages Array of QBChatMessage instances to replace
 *  @param dialogID Chat dialog identifier
 */
- (void)replaceMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Updates message in memory storage. Dialog ID is taken from message.
 *
 *  @param message Updated message.
 */
- (void)updateMessage:(QB_NONNULL QBChatMessage *)message;

#pragma mark - Getters

/**
 *  Messages with chat dialog identifier
 *
 *  @param dialogID Chat dialog identifier
 *
 *  @return return array of QBChatMessage instances
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messagesWithDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Delete message from memory storage.
 *
 *  @param message message to delete.
 */
- (void)deleteMessage:(QB_NONNULL QBChatMessage *)message;

/**
 *  Delete messages from memory storage.
 *
 *  @param messages messages to delete
 *  @param dialogID chat dialog identifier
 */
- (void)deleteMessages:(QB_NONNULL NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Delete messages with dialog indetifier
 *
 *  @param dialogID Chat dialog identifier
 */
- (void)deleteMessagesWithDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Message with ID
 *
 *  @param messageID Message identifier
 *
 *  @return QBChatMessage object
 */
- (QB_NULLABLE QBChatMessage *)messageWithID:(QB_NONNULL NSString *)messageID fromDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Get last message in memory storage from dialog by ID
 *
 *  @param dialogID dialog ID
 *
 *  @return QBChatMessage object
 */
- (QB_NULLABLE QBChatMessage *)lastMessageFromDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Is message existent for dialog.
 *
 *  @param message  QBChatMessage instance
 *  @param dialogID dialog ID
 *
 *  @return whether message existent for a specific dialog
 */
- (BOOL)isMessageExistent:(QB_NONNULL QBChatMessage *)message forDialogID:(QB_NONNULL NSString *)dialogID;

#pragma mark - Helpers

/**
 *  Checks if dialog doesn't have messages
 *
 *  @param dialogID dialog ID
 *
 *  @return YES if dialog empty
 */
- (BOOL)isEmptyForDialogID:(QB_NONNULL NSString *)dialogID;

/**
 *  Get first message in memory storage from dialog by ID
 *
 *  @param dialogID dialog ID
 *
 *  @return QBChatMessage object
 */
- (QB_NULLABLE QBChatMessage *)oldestMessageForDialogID:(QB_NONNULL NSString *)dialogID;

@end
