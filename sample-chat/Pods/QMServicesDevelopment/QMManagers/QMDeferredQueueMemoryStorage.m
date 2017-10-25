//
//  QMDeferredQueueMemoryStorage.m
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDeferredQueueMemoryStorage.h"

@interface QMDeferredQueueMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary<NSString *, QBChatMessage *> *messagesInQueue;

@end

@implementation QMDeferredQueueMemoryStorage

- (void)dealloc {
    
    [self.messagesInQueue removeAllObjects];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _messagesInQueue = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addMessage:(QBChatMessage *)message {
    
    NSAssert(message != nil, @"Message is nil!");
    NSAssert(message.ID != nil, @"Messagewithout identifier!");
    
//    QBChatMessage *localMessage = self.messagesInQueue[message.ID];
//
//    if (!localMessage) {
       self.messagesInQueue[message.ID] = message;
//    }
}

- (void)removeMessage:(QBChatMessage *)message {
    
    [self.messagesInQueue removeObjectForKey:message.ID];
}

- (BOOL)containsMessage:(QBChatMessage *)message {
    
    return self.messagesInQueue[message.ID] != nil;
}

- (NSArray<QBChatMessage *> *)messages {
    
    NSSortDescriptor *dateSentDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES];
    NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
    
    return [self sortedMessagesUsingDescriptors:@[dateSentDescriptor,idDescriptor]];
}

- (NSArray<QBChatMessage *> *)sortedMessagesUsingDescriptors:(NSArray <NSSortDescriptor *> *)descriptors {
    
    NSArray *sortedMessages = [self.messagesInQueue.allValues sortedArrayUsingDescriptors:descriptors];
    
    return sortedMessages;
}

//MARK: QMMemoryStorageProtocol

- (void)free {
    
    [self.messagesInQueue removeAllObjects];
}

@end
