//
//  QMChatDataSource.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "NSDate+ChatDataSource.h"

@interface QMChatDataSource()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableSet *dateDividers;
@property (strong, nonatomic) dispatch_queue_t serialQueue;

@end

static NSComparator messageComparator = ^(QBChatMessage *obj1, QBChatMessage *obj2) {
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:NO];
    
    NSComparisonResult result = [obj2.dateSent compareWithDate:obj1.dateSent];
    
    if (result != NSOrderedSame) {
        return result;
    }
    else {
        return [desc compareObject:obj1 toObject:obj2];
    }
    
};


@implementation QMChatDataSource

#pragma mark -
#pragma mark Initialization

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _dateDividers = [NSMutableSet set];
        _messages = [NSMutableArray array];
        _serialQueue = dispatch_queue_create("com.qmchatvc.datasource.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"\n[QMDataSource] \n\t messages: %@", self.allMessages];
}

#pragma mark -
#pragma mark Adding

- (void)addMessage:(QBChatMessage *)message {
    [self addMessages:@[message]];
}

- (void)addMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceUpdateTypeAdd];
}

#pragma mark -
#pragma mark Removing

- (void)deleteMessage:(QBChatMessage *)message {
    [self deleteMessages:@[message]];
}

- (void)deleteMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceUpdateTypeRemove];
}

- (void)updateMessage:(QBChatMessage *)message {
    [self updateMessages:@[message]];
}

- (void)updateMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceUpdateTypeUpdate];
}

#pragma mark -
#pragma mark - Data Source

- (void)changeDataSourceWithMessages:(NSArray*)messages forUpdateType:(QMDataSourceUpdateType)updateType {
    
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *itemsIndexPaths = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messageIDs = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        
        for (QBChatMessage *message in messages) {
            
            NSAssert(message.dateSent != nil, @"Message must have dateSent!");
            
            if ([self shouldSkipMessage:message forDataSourceUpdateType:updateType]) {
                continue;
            }
            
            if (updateType == QMDataSourceUpdateTypeUpdate) {
                
                NSIndexPath *indexPath = [self indexPathForMessage:message];
                NSUInteger updatedMessageIndex = [self indexThatConformsToMessage:message];
                
                if (updatedMessageIndex != indexPath.item && updatedMessageIndex!= NSNotFound) {
                    // message will have new indexPath due to date changes
                    [self deleteMessages:@[message]];
                    [self addMessages:@[message]];
                }
                else {
                    [messagesArray addObject:message];
                }
                
            }
            else {
                [messagesArray addObject:message];
            }
            
            QBChatMessage * dividerMessage = [self handleMessage:message forUpdateType:updateType];
            
            if (dividerMessage) {
                [messagesArray addObject:dividerMessage];
                [messageIDs addObject:dividerMessage.ID];
            }
            
            [messageIDs addObject:message.ID];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (messageIDs.count) {
                
                [self.delegate chatDataSource:self willBeChangedWithMessageIDs:messageIDs];
            }
            
            if (messagesArray.count) {
                
                [self.delegate changeDataSource:self withMessages:messagesArray updateType:updateType];
            }
            
        });
    });
}

- (NSArray *)performChangesWithMessages:(NSArray *)messages updateType:(QMDataSourceUpdateType)updateType {
    
    NSArray *indexPathes = [NSMutableArray arrayWithCapacity:messages.count];
    
    if (updateType == QMDataSourceUpdateTypeRemove) {
        
        indexPathes = [self indexPathesForMessages:messages];
    }
    
    for (QBChatMessage *msg in messages) {
        
        if (updateType == QMDataSourceUpdateTypeAdd) {
            [self insertMessage:msg];
        }
        else if (updateType == QMDataSourceUpdateTypeUpdate) {
            
            [self.messages replaceObjectAtIndex:[self indexPathForMessage:msg].item withObject:msg];
        }
        
        else if (QMDataSourceUpdateTypeRemove) {
            
            [self.messages removeObjectAtIndex:[self indexPathForMessage:msg].item];
        }
    }
    
    if (updateType == QMDataSourceUpdateTypeAdd || updateType == QMDataSourceUpdateTypeUpdate) {
        
        indexPathes = [self indexPathesForMessages:messages];
    }

    return indexPathes;
}

- (NSArray *)indexPathesForMessages:(NSArray *)messages {
    
    NSMutableArray *indexPathes = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (QBChatMessage *msg in messages) {
        
        NSIndexPath *indexPath = [self indexPathForMessage:msg];
        if (indexPath) {
            [indexPathes addObject:indexPath];
        }
    }
    
    return [NSArray arrayWithArray:indexPathes];
}

- (BOOL)shouldSkipMessage:(QBChatMessage *)message forDataSourceUpdateType:(QMDataSourceUpdateType)updateType {
    
    BOOL messageExists = [self messageExists:message];
    
    if (updateType == QMDataSourceUpdateTypeAdd) {
        
        return messageExists;
    }
    else {
        return !messageExists;
    }
}


- (void)calDelegateMethodForIndexPaths:(NSArray *)indexPaths withUpdateType:(QMDataSourceUpdateType)updateType {
    
    switch (updateType) {
            
        case QMDataSourceUpdateTypeAdd: {
            [self.delegate chatDataSource:self didInsertMessagesAtIndexPaths:indexPaths];
            break;
        }
        case QMDataSourceUpdateTypeUpdate: {
            [self.delegate chatDataSource:self didUpdateMessagesAtIndexPaths:indexPaths];
            break;
        }
        case QMDataSourceUpdateTypeRemove: {
            [self.delegate chatDataSource:self didDeleteMessagesAtIndexPaths:indexPaths];
            break;
        }
    }
}

#pragma mark -
#pragma mark - Helpers

- (NSArray *)allMessages {
    
    return [NSArray arrayWithArray:_messages];
}

- (NSInteger)messagesCount {
    
    return self.allMessages.count;
}

- (NSUInteger)insertMessage:(QBChatMessage *)message {
    
    NSUInteger index = [self indexThatConformsToMessage:message];
    [self.messages insertObject:message atIndex:index];
    
    return index;
}

- (QBChatMessage *)messageForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == NSNotFound) {
        return nil;
    }
    
    return self.allMessages[indexPath.item];
}


- (BOOL)messageExists:(QBChatMessage *)message {
    
    return [self.allMessages containsObject:message];
}

- (NSUInteger)indexThatConformsToMessage:(QBChatMessage *)message {
    
    NSArray *messages = self.allMessages;
    
    NSUInteger index = [messages indexOfObject:message
                                 inSortedRange:(NSRange){0, [messages count]}
                                       options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
                               usingComparator:messageComparator];
    
    return index;
}

- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message {
    
    NSIndexPath *indexPath = nil;
    
    if ([self.allMessages containsObject:message]) {
        
        indexPath = [NSIndexPath indexPathForItem:[self.allMessages indexOfObject:message] inSection:0];
    }
    
    return indexPath;
}

- (BOOL)hasMessages:(QBChatMessage *)messageToUpdate forUpdateType:(QMDataSourceUpdateType)updateType {

    NSDate *startDate = [messageToUpdate.dateSent dateAtStartOfDay];
    NSDate *endDate = [messageToUpdate.dateSent dateAtEndOfDay];
    
    NSPredicate *predicate;
    
    if (updateType == QMDataSourceUpdateTypeRemove) {
        predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage*  _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
            return !message.isDateDividerMessage && [message.dateSent isBetweenStartDate:startDate andEndDate:endDate] && message.ID != messageToUpdate.ID;
        }];

       }
    else {
        predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage*  _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
            return !message.isDateDividerMessage && [message.dateSent isBetweenStartDate:startDate andEndDate:endDate];
        }];

    }
    
    NSArray *messages = [self.allMessages filteredArrayUsingPredicate:predicate];
    
    return messages.count > 0;
    
}

#pragma mark -
#pragma mark - Date Dividers

- (QBChatMessage *)handleMessage:(QBChatMessage *)message forUpdateType:(QMDataSourceUpdateType)updateType {
    
    if (message.isDateDividerMessage) {
        return nil;
    }
    
    NSDate *dateToAdd = [message.dateSent dateAtStartOfDay];
    
    if (updateType == QMDataSourceUpdateTypeAdd) {
        
        if ([self.dateDividers containsObject:dateToAdd]) {
            return nil;
        }
        
        QBChatMessage *divideMessage = [QBChatMessage new];
        
        divideMessage.text = dateToAdd.stringDate;
        divideMessage.dateSent = dateToAdd;
        
        divideMessage.isDateDividerMessage = YES;
        
        [self.dateDividers addObject:dateToAdd];
        
        return divideMessage;
    }
    else {
        
        BOOL hasMessages = [self hasMessages:message forUpdateType:updateType];
        
        if (hasMessages) {
            return nil;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage*  _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
            return message.isDateDividerMessage && [message.dateSent isEqualToDate:dateToAdd];
        }];
        
        QBChatMessage *msg = [[self.allMessages filteredArrayUsingPredicate:predicate] firstObject];
        [self.dateDividers removeObject:dateToAdd];
        
        if (updateType == QMDataSourceUpdateTypeUpdate) {
            
            [self deleteMessage:msg];
            return nil;
        }
        else {
            return msg;
        }
    }
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    
    return [_messages countByEnumeratingWithState:state objects:buffer count:len];
}

@end
