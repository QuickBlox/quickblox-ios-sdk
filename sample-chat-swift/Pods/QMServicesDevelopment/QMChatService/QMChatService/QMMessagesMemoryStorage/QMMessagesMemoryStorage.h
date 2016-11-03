//
//  QMMessagesMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 28.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

@protocol QMMemoryTemporaryQueueDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QMMessagesMemoryStorage : NSObject <QMMemoryStorageProtocol>

@property (weak, nonatomic, nullable) id <QMMemoryTemporaryQueueDelegate> delegate;

/**
 *  Add message to memory storage
 *
 *  @param message  QBChatMessage instnace
 *  @param dialogID Chat dialog identifier
 */
- (void)addMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Add messages to memory storage
 *
 *  @param messages Array of QBChatMessage items
 *  @param dialogID Chat dialog identifier
 */
- (void)addMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(NSString *)dialogID;

/**
 *  Replace messages in memory storage for dialog identifier
 *
 *  @param messages Array of QBChatMessage instances to replace
 *  @param dialogID Chat dialog identifier
 */
- (void)replaceMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(NSString *)dialogID;

/**
 *  Updates message in memory storage. Dialog ID is taken from message.
 *
 *  @param message Updated message.
 */
- (void)updateMessage:(QBChatMessage *)message;

#pragma mark - Getters

/**
 *  Messages with chat dialog identifier
 *
 *  @param dialogID Chat dialog identifier
 *
 *  @return return array of QBChatMessage instances
 */
- (NSArray QB_GENERIC(QBChatMessage *) *)messagesWithDialogID:(NSString *)dialogID;

/**
 *  Delete message from memory storage.
 *
 *  @param message message to delete.
 */
- (void)deleteMessage:(QBChatMessage *)message;

/**
 *  Delete messages from memory storage.
 *
 *  @param messages messages to delete
 *  @param dialogID chat dialog identifier
 */
- (void)deleteMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(NSString *)dialogID;

/**
 *  Delete messages with dialog indetifier
 *
 *  @param dialogID Chat dialog identifier
 */
- (void)deleteMessagesWithDialogID:(NSString *)dialogID;

/**
 *  Message with ID
 *
 *  @param messageID Message identifier
 *
 *  @return QBChatMessage object
 */
- (nullable QBChatMessage *)messageWithID:(NSString *)messageID fromDialogID:(NSString *)dialogID;

/**
 *  Get last message in memory storage from dialog by ID
 *
 *  @param dialogID dialog ID
 *
 *  @return QBChatMessage object
 */
- (nullable QBChatMessage *)lastMessageFromDialogID:(NSString *)dialogID;

/**
 *  Is message existent for dialog.
 *
 *  @param message  QBChatMessage instance
 *  @param dialogID dialog ID
 *
 *  @return whether message existent for a specific dialog
 */
- (BOOL)isMessageExistent:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

#pragma mark - Helpers

/**
 *  Checks if dialog doesn't have messages
 *
 *  @param dialogID dialog ID
 *
 *  @return YES if dialog empty
 */
- (BOOL)isEmptyForDialogID:(NSString *)dialogID;

/**
 *  Get first message in memory storage from dialog by ID
 *
 *  @param dialogID dialog ID
 *
 *  @return QBChatMessage object
 */
- (nullable QBChatMessage *)oldestMessageForDialogID:(NSString *)dialogID;

@end

@protocol QMMemoryTemporaryQueueDelegate <NSObject>

@optional

- (nullable NSArray *)localMessagesForDialogWithID:(NSString *)dialogID;

@end

NS_ASSUME_NONNULL_END
