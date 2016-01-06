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
- (void)addChatDialog:(QBChatDialog *)chatDialog andJoin:(BOOL)join completion:(void(^)(QBChatDialog *addedDialog, NSError *error))completion;

/**
 *  Add dialogs to memory storage
 *
 *  @param dialogs QBChatDialog items
 *  @param join YES to join in dialog immediately
 */
- (void)addChatDialogs:(NSArray *)dialogs andJoin:(BOOL)join;

/**
 *  Delete dialog from memory storage
 *
 *  @param chatDialogID item ID to delete
 */
- (void)deleteChatDialogWithID:(NSString *)chatDialogID;

/**
 *  Find dialog in memory storage by ID
 *
 *  @param dialogID chat dialog ID
 *
 *  @return QBChatDialog instance
 */
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

/**
 *  Find private dialog in memory storage by opponent ID
 *
 *  @param opponentID opponent ID
 *
 *  @return QBChatDialog instance
 */
- (QBChatDialog *)privateChatDialogWithOpponentID:(NSUInteger)opponentID;

/**
 *  Get dialogs with unread messages in memory storage
 *
 *  @return Array of QBChatDialog items
 */
- (NSArray *)unreadDialogs;

/**
 *  Get all dialogs in memory storage
 *
 *  @return Array of QBChatDialog items
 */
- (NSArray *)unsortedDialogs;

/**
 *  Get all dialogs in memory storage sorted by last message date
 *
 *  @param ascending sorting parameter
 *
 *  @return Array of QBChatDialog items
 */
- (NSArray *)dialogsSortByLastMessageDateWithAscending:(BOOL)ascending;

/**
 *  Get all dialogs in memory storage sorted by updated at
 *
 *  @param ascending sorting parameter
 *
 *  @return Array of QBChatDialog items
 */
- (NSArray *)dialogsSortByUpdatedAtWithAscending:(BOOL)ascending;

/**
 *  Get all dialogs in memory storage sorted by sort descriptors
 *
 *  @param descriptors Array of NSSortDescriptors
 *
 *  @return Array of QBChatDialog items
 */
- (NSArray *)dialogsWithSortDescriptors:(NSArray *)descriptors;

@end
