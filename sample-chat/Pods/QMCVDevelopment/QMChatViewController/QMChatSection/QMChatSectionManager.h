//
//  QMChatSectionManager.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 2/2/16.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@class QBChatMessage;
@class QMChatSectionManager;
@class QMChatSection;

/**
 *  QMChatSectionManagerDelegate protocol.
 *  Used to notify about data source changes to allow you perform any operations on its completion.
 */
@protocol QMChatSectionManagerDelegate <NSObject>

@required
/**
 *  QMChatSectionManager delegate method about sections and/or items that were inserted to data source.
 *
 *  @param chatSectionManager QMChatSectionManager current instance
 *  @param sectionsIndexSet   index set of sections
 *  @param itemsIndexPaths    array of items index paths
 *  @param animated           determines whether perform animated view update or not
 */
- (void)chatSectionManager:(QMChatSectionManager *)chatSectionManager didInsertSections:(NSIndexSet *)sectionsIndexSet andItems:(NSArray *)itemsIndexPaths animated:(BOOL)animated;

/**
 *  QMChatSectionManager delegate method about items were updated in data source.
 *
 *  @param chatSectionManager QMChatSectionManager current instance
 *  @param messagesIDs        ids of updated messages
 *  @param itemsIndexPaths    array of items index paths
 */
- (void)chatSectionManager:(QMChatSectionManager *)chatSectionManager didUpdateMessagesWithIDs:(NSArray *)messagesIDs atIndexPaths:(NSArray *)itemsIndexPaths;

/**
 *  QMChatSectionManager delegate method about sections and/or items were deleted from data source.
 *
 *  @param chatSectionManager QMChatSectionManager current instance
 *  @param messagesIDs        ids of deleted messages
 *  @param itemsIndexPaths    array of items index paths
 *  @param sectionsIndexSet   index set of sections
 *  @param animated           determines whether perform animated view update or not
 */
- (void)chatSectionManager:(QMChatSectionManager *)chatSectionManager didDeleteMessagesWithIDs:(NSArray *)messagesIDs atIndexPaths:(NSArray *)itemsIndexPaths withSectionsIndexSet:(NSIndexSet *)sectionsIndexSet animated:(BOOL)animated;

@end

/**
 *  QMChatSectionManager class overview:
 *  This class is used to manage QMChatViewController data source with sections and its items.
 */
@interface QMChatSectionManager : NSObject

#pragma mark - Properties

/**
 *  Time interval between sections.
 *  Default value: 300 seconds
 *
 *  @discussion Set this value to 0 (zero) to hide all sections.
 */
@property (assign, nonatomic) NSTimeInterval timeIntervalBetweenSections;

/**
 *  Total count of messages in all sections.
 *
 *  @discussion Use this to know how many messages are displayed in chat controller.
 */
@property (assign, nonatomic, readonly) NSUInteger totalMessagesCount;

/**
 *  Determines whether animation for inserting or deleting is enabled.
 *  Default value: YES
 */
@property (assign, nonatomic) BOOL animationEnabled;

/**
 *  QMChatSectionManager delegate to notify about data source updates.
 *
 *  @see QMChatSectionManagerDelegate protocol declaration.
 */
@property (weak, nonatomic) id <QMChatSectionManagerDelegate> delegate;

#pragma mark - Add messages

/**
 *  Add message to data source.
 *
 *  @param message QBChatMessage instance to add
 */
- (void)addMessage:(QBChatMessage *)message;

/**
 *  Add messages to data source.
 *
 *  @param messages array of QBChatMessage instances to add
 */
- (void)addMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

#pragma mark - Update messages

/**
 *  Update message in data source.
 *
 *  @param message QBChatMessage instance to update
 */
- (void)updateMessage:(QBChatMessage *)message;

/**
 *  Update messages in data source.
 *
 *  @param messages array of QBChatMessage instances to update
 */
- (void)updateMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

#pragma mark - Delete messages

/**
 *  Delete message from data source.
 *
 *  @param message QBChatMessage instance to delete
 */
- (void)deleteMessage:(QBChatMessage *)message;

/**
 *  Delete messages from data source.
 *
 *  @param messages array of QBChatMessage instances to delete
 */
- (void)deleteMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

#pragma mark - Helper methods

/**
 *  Determines whether data source is empty.
 *
 *  @return boolean value of data source being empty
 */
- (BOOL)isEmpty;

/**
 *  Determines how many sections are exist in data source.
 *
 *  @return number of sections in data source
 */
- (NSInteger)chatSectionsCount;

/**
 *  Determines how many messages are exist in a specific section in data source.
 *
 *  @param sectionIndex index of section
 *
 *  @return number of messages in a specific section
 */
- (NSInteger)messagesCountForSectionAtIndex:(NSInteger)sectionIndex;

/**
 *  QMChatSection instance that exists in a specific index.
 *
 *  @param sectionIndex index of a specific section
 *
 *  @return QMChatSection instance that exists in a specific index
 */
- (QMChatSection *)chatSectionAtIndex:(NSInteger)sectionIndex;

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

@end
