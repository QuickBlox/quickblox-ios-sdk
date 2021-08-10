//
//  ChatDataSource.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DataSourceActionType) {
    
    DataSourceActionTypeAdd = 0,
    DataSourceActionTypeUpdate,
    DataSourceActionTypeRemove
};


@class QBChatMessage;

@protocol ChatDataSourceDelegate;

@interface ChatDataSource : NSObject <NSFastEnumeration>

@property(nonatomic, weak) id <ChatDataSourceDelegate> delegate;

- (NSArray *)allMessages;

- (void)addMessage:(QBChatMessage *)message;
- (void)addMessages:(NSArray<QBChatMessage *> *)messages;

- (void)deleteMessage:(QBChatMessage *)message;
- (void)deleteMessages:(NSArray <QBChatMessage *> *)messages;

- (void)clear;

- (void)updateMessage:(QBChatMessage *)message;
- (void)updateMessages:(NSArray <QBChatMessage *> *)messages;

- (NSArray *)performChangesWithMessages:(NSArray *)messages updateType:(DataSourceActionType)updateType;

- (NSInteger)loadMessagesCount;

- (NSArray *)allMessagesForRead;
- (void)addMessageForRead:(QBChatMessage *)message;
- (void)removeMessageForRead:(QBChatMessage *)message;
- (NSInteger)messagesForReadCount;

- (NSArray *)allDraftMessages;
- (void)addDraftMessage:(QBChatMessage *)message;
- (void)removeDraftMessage:(QBChatMessage *)message;
- (NSInteger)draftMessagesCount;

/**
 *  Messages count.
 *
 *  @return The number of messages in the data source
 */
- (NSInteger)messagesCount;

- (QBChatMessage *)messageWithID:(NSString *)ID;
/**
 *  Message for index path.
 *
 *  @param indexPath    index path to find message
 *
 *  @return QBChatMessage instance that conforms to indexPath
 */
- (QBChatMessage *)messageWithIndexPath:(NSIndexPath *)indexPath;

/**
 *  Index path for message.
 *
 *  @param message  message to return index path
 *
 *  @return NSIndexPath instance that conforms message or nil if not found
 */
- (NSIndexPath *)messageIndexPath:(QBChatMessage *)message;

/**
 *  Returns a Boolean value that indicates whether a message is present in the data source.
 *
 *  @param message message to check
 *
 *  @return YES if message is present in the data source, otherwise NO.
 */
- (BOOL)isExistMessage:(QBChatMessage *)message;

@end

@protocol ChatDataSourceDelegate <NSObject>

- (void)chatDataSource:(ChatDataSource *)chatDataSource
willBeChangedWithMessageIDs:(NSArray *)messagesIDs;

- (void)chatDataSource:(ChatDataSource *)dataSource
            changeWithMessages:(NSArray *)messages
              action:(DataSourceActionType)action;

@end


NS_ASSUME_NONNULL_END
