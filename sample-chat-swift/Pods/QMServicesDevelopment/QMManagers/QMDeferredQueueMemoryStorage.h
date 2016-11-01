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

@interface QMDeferredQueueMemoryStorage : NSObject <QMMemoryStorageProtocol>

- (void)addMessage:(QB_NONNULL QBChatMessage *)message;

- (void)removeMessage:(QB_NONNULL QBChatMessage *)message;

- (void)addMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;
- (void)removeMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

- (BOOL)containsMessage:(QB_NONNULL QBChatMessage *)message;

- (QB_NULLABLE NSArray QB_GENERIC(QBChatMessage *) *)messages;
- (QB_NULLABLE NSArray QB_GENERIC(QBChatMessage *) *)messagesSortedWithDescriptors:(QB_NONNULL NSArray QB_GENERIC(NSSortDescriptor*) *)descriptors;

@end
