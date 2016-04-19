//
//  QMDialogsMemoryStorage.h
//  QMServices
//
//  Created by Andrey on 03.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "QMMemoryStorageProtocol.h"

@interface QMDialogsMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 *  Add dialog to memory storage.
 *
 *  @param chatDialog  QBChatDialog instnace
 *  @param join        YES to join in dialog immediately
 *  @param completion  completion block with error if failed or nil if succeed
 */
- (void)addChatDialog:(QB_NONNULL QBChatDialog *)chatDialog andJoin:(BOOL)join completion:(void(^QB_NULLABLE_S)(QBChatDialog * QB_NONNULL_S addedDialog, NSError * QB_NULLABLE_S error))completion;

/**
 *  Add dialogs to memory storage
 *
 *  @param dialogs QBChatDialog items
 *  @param join YES to join in dialog immediately
 */
- (void)addChatDialogs:(QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogs andJoin:(BOOL)join;

/**
 *  Delete dialog from memory storage
 *
 *  @param chatDialogID item ID to delete
 */
- (void)deleteChatDialogWithID:(QB_NONNULL NSString *)chatDialogID;

/**
 *  Find dialog in memory storage by ID
 *
 *  @param dialogID chat dialog ID
 *
 *  @return QBChatDialog instance
 */
- (QB_NULLABLE QBChatDialog *)chatDialogWithID:(QB_NONNULL NSString *)dialogID;

/**
 *  Find private dialog in memory storage by opponent ID
 *
 *  @param opponentID opponent ID
 *
 *  @return QBChatDialog instance
 */
- (QB_NULLABLE QBChatDialog *)privateChatDialogWithOpponentID:(NSUInteger)opponentID;

/**
 *  Get dialogs with unread messages in memory storage
 *
 *  @return Array of QBChatDialog items
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)unreadDialogs;

/**
 *  Get all dialogs with specific user ids.
 *
 *  @param usersIDs array of users ids
 *
 *  @return array of finded QBChatDialog's
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)chatDialogsWithUsersIDs:(QB_NONNULL NSArray QB_GENERIC(NSNumber *) *)usersIDs;

/**
 *  Get all dialogs in memory storage
 *
 *  @return Array of QBChatDialog items
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)unsortedDialogs;

/**
 *  Get all dialogs in memory storage sorted by last message date
 *
 *  @param ascending sorting parameter
 *
 *  @return Array of QBChatDialog items
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogsSortByLastMessageDateWithAscending:(BOOL)ascending;

/**
 *  Get all dialogs in memory storage sorted by updated at
 *
 *  @param ascending sorting parameter
 *
 *  @return Array of QBChatDialog items
 */
- (QB_NONNULL NSArray QB_GENERIC(QBChatDialog *) *)dialogsSortByUpdatedAtWithAscending:(BOOL)ascending;

/**
 *  Get all dialogs in memory storage sorted by sort descriptors
 *
 *  @param descriptors Array of NSSortDescriptors
 *
 *  @return Array of QBChatDialog items
 */
- (QB_NULLABLE NSArray QB_GENERIC(QBChatDialog *) *)dialogsWithSortDescriptors:(QB_NONNULL NSArray QB_GENERIC(NSSortDescriptor *) *)descriptors;

@end
