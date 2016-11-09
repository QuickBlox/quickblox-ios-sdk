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

- (void)addMessage:(QBChatMessage *)message;

- (void)removeMessage:(QBChatMessage *)message;

- (void)addMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;
- (void)removeMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

- (BOOL)containsMessage:(QBChatMessage *)message;

- (NSArray QB_GENERIC(QBChatMessage *) *)messages;
- (NSArray QB_GENERIC(QBChatMessage *) *)messagesSortedWithDescriptors:(NSArray QB_GENERIC(NSSortDescriptor*) *)descriptors;

@end

NS_ASSUME_NONNULL_END
