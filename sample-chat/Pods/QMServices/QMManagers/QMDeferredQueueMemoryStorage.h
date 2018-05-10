//
//  QMDeferredQueueMemoryStorage.h
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMDeferredQueueMemoryStorage : NSObject <QMMemoryStorageProtocol>

/**
 Add message to memory storage

 @param message QBChatMessage instance
 */
- (void)addMessage:(QBChatMessage *)message;

/**
 Remove message from memory storage
 
 @param message QBChatMessage instance
 */
- (void)removeMessage:(QBChatMessage *)message;

/**
 Check message is contains in memory storage

 @param message QBChatMessage instance
 @return return YES if message containts in memory storage
 */
- (BOOL)containsMessage:(QBChatMessage *)message;

//MARK: Filters

/**
 Get messages sorted by dateSent

 @return Array of QBChatMessage's
 */
- (NSArray<QBChatMessage *> *)messages;


/**
 Get sorted messages using descriptors

 @param descriptors Array of NSSortDescriptor
 @return Array of QBChatMessage's
 */
- (NSArray<QBChatMessage *> *)sortedMessagesUsingDescriptors:(NSArray <NSSortDescriptor *> *)descriptors;

@end

NS_ASSUME_NONNULL_END
