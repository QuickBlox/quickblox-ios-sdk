//
//  QMDeferredQueueMemoryStorage.m
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDeferredQueueMemoryStorage.h"

@interface QMDeferredQueueMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *messagesInQueue;
@property (strong, nonatomic) NSMutableDictionary *dialogs;
@property (strong, nonatomic) NSMutableDictionary *contactRequests;

@end

@implementation QMDeferredQueueMemoryStorage

- (void)dealloc {
    [self.messagesInQueue removeAllObjects];
    [self.dialogs removeAllObjects];
    [self.contactRequests removeAllObjects];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.dialogs = [NSMutableDictionary dictionary];
        self.messagesInQueue = [NSMutableDictionary dictionary];
        self.contactRequests = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)addMessage:(QBChatMessage *)message {
    
    QBChatMessage *localMessage = self.messagesInQueue[message.ID];
    
    if (localMessage != nil) {
        localMessage = [message copy];
    }
    else {
        self.messagesInQueue[message.ID] = message;
    }
}

- (void)removeMessage:(QBChatMessage *)message {
    [self.messagesInQueue removeObjectForKey:message.ID];
}

- (BOOL)containsMessage:(QBChatMessage *)message {
    return [self.messagesInQueue.allKeys containsObject:message.ID];
}

- (QB_NULLABLE NSArray QB_GENERIC(QBChatMessage *) *)messages {
    
    NSSortDescriptor *dateSentDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES];
    NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
    
    return [self messagesSortedWithDescriptors:@[dateSentDescriptor,idDescriptor]];
}

- (QB_NULLABLE NSArray QB_GENERIC(QBChatMessage *) *)messagesSortedWithDescriptors:(QB_NONNULL NSArray QB_GENERIC(NSSortDescriptor*) *)descriptors {
    
    NSArray *sortedMessages = [self.messagesInQueue.allValues sortedArrayUsingDescriptors:descriptors];
    
    return sortedMessages;
}


#pragma mark - QMMemoryStorageProtocol

- (void)free {
    [self.messagesInQueue removeAllObjects];
    [self.dialogs removeAllObjects];
    [self.contactRequests removeAllObjects];
}

@end
