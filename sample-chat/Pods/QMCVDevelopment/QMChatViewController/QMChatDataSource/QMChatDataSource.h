//
//  QMChatDataSource.h
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

#import "QBChatMessage+QBDateDivider.h"

typedef NS_ENUM(NSInteger, QMDataSourceActionType) {

    QMDataSourceActionTypeAdd = 0,
    QMDataSourceActionTypeUpdate,
    QMDataSourceActionTypeRemove
};

@class QBChatMessage;

@protocol QMChatDataSourceDelegate;


@interface QMChatDataSource : NSObject <NSFastEnumeration>

@property(nonatomic, weak) id <QMChatDataSourceDelegate> delegate;

- (NSArray *)allMessages;

- (void)addMessage:(QBChatMessage *)message;
- (void)addMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

- (void)deleteMessage:(QBChatMessage *)message;
- (void)deleteMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

- (void)updateMessage:(QBChatMessage *)message;
- (void)updateMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

- (NSArray *)performChangesWithMessages:(NSArray *)messages updateType:(QMDataSourceActionType)updateType;

/**
 *  Messages count.
 *
 *  @return The number of messages in the data source
 */
- (NSInteger)messagesCount;

/**
 *  Message for index path.
 *
 *  @param indexPath    index path to find message
 *
 *  @return QBChatMessage instance that conforms to indexPath
 */
- (QBChatMessage *)messageForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Index path for message.
 *
 *  @param message  message to return index path
 *
 *  @return NSIndexPath instance that conforms message or nil if not found
 */
- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message;

/**
 *  Returns a Boolean value that indicates whether a message is present in the data source.
 *
 *  @param message message to check
 *
 *  @return YES if message is present in the data source, otherwise NO.
 */
- (BOOL)messageExists:(QBChatMessage *)message;

@end

@protocol QMChatDataSourceDelegate <NSObject>

- (void)chatDataSource:(QMChatDataSource *)chatDataSource willBeChangedWithMessageIDs:(NSArray *)messagesIDs;

- (void)changeDataSource:(QMChatDataSource *)dataSource withMessages:(NSArray *)messages updateType:(QMDataSourceActionType)updateType;

@end
