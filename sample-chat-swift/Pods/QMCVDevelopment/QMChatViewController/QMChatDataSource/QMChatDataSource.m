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

@end

@implementation QMChatDataSource

NSComparator messageComparator = ^(QBChatMessage *obj1, QBChatMessage *obj2) {
    
    NSComparisonResult result = [obj2.dateSent compareWithDate:obj1.dateSent];
    
    if (result != NSOrderedSame) {
        return result;
    }
    else {
        
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:NO];
        NSComparisonResult idResult =  [desc compareObject:obj1 toObject:obj2];
        return idResult;
    }
};

static dispatch_queue_t _serialQueue = nil;

#pragma mark -
#pragma mark Initialization

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _serialQueue = dispatch_queue_create("com.qmchatvc.datasource.queue", DISPATCH_QUEUE_SERIAL);
        });
        
        _dateDividers = [NSMutableSet set];
        _messages = [NSMutableArray array];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[QMDataSource] \n\t messages: %@", self.allMessages];
}

#pragma mark -
#pragma mark Adding

- (void)addMessage:(QBChatMessage *)message {
    [self addMessages:@[message]];
}

- (void)addMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeAdd];
}

#pragma mark -
#pragma mark Removing

- (void)deleteMessage:(QBChatMessage *)message {
    [self deleteMessages:@[message]];
}

- (void)deleteMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeRemove];
}

#pragma mark -
#pragma mark Updating

- (void)updateMessage:(QBChatMessage *)message {
    [self updateMessages:@[message]];
}

- (void)updateMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeUpdate];
}

#pragma mark -
#pragma mark - Data Source

- (void)changeDataSourceWithMessages:(NSArray*)messages forUpdateType:(QMDataSourceActionType)updateType {
    
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *messageIDs = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        
        for (QBChatMessage *message in messages) {
            
            NSAssert(message.dateSent != nil, @"Message must have dateSent!");
            
            if ([self shouldSkipMessage:message forDataSourceUpdateType:updateType]) {
                continue;
            }
            
            if (updateType == QMDataSourceActionTypeUpdate) {
                
                NSIndexPath *indexPath = [self indexPathForMessage:message];
                NSUInteger updatedMessageIndex = [self indexThatConformsToMessage:message];
                
                if (updatedMessageIndex != indexPath.item) {
                    
                    [self deleteMessage:message];
                    [self addMessage:message];
                    return;
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
            
            if (messageIDs.count && updateType != QMDataSourceActionTypeAdd) {
                
                [self.delegate chatDataSource:self willBeChangedWithMessageIDs:messageIDs];
            }
            
            if (messagesArray.count) {
                
                [self.delegate changeDataSource:self withMessages:messagesArray updateType:updateType];
            }
            
        });
    });
}

- (NSArray *)performChangesWithMessages:(NSArray *)messages updateType:(QMDataSourceActionType)updateType {
    
    NSArray *indexPaths = [NSMutableArray arrayWithCapacity:messages.count];
    
    if (updateType == QMDataSourceActionTypeRemove) {
        
        indexPaths = [self indexPathsForMessages:messages];
    }
    
    for (QBChatMessage *msg in messages) {
        
        if (updateType == QMDataSourceActionTypeAdd) {
            
            [self insertMessage:msg];
        }
        else if (updateType == QMDataSourceActionTypeUpdate) {
            
            self.messages[[self indexPathForMessage:msg].item] = msg;
        }
        
        else if (QMDataSourceActionTypeRemove) {
            
            [self.messages removeObjectAtIndex:[self indexPathForMessage:msg].item];
        }
    }
    
    if (updateType == QMDataSourceActionTypeAdd || updateType == QMDataSourceActionTypeUpdate) {
        
        indexPaths = [self indexPathsForMessages:messages];
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsForMessages:(NSArray *)messages {
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (QBChatMessage *msg in messages) {
        
        NSIndexPath *indexPath = [self indexPathForMessage:msg];
        if (indexPath) {
            [indexPaths addObject:indexPath];
        }
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

- (BOOL)shouldSkipMessage:(QBChatMessage *)message forDataSourceUpdateType:(QMDataSourceActionType)updateType {
    
    BOOL messageExists = [self messageExists:message];
    
    return (updateType == QMDataSourceActionTypeAdd ? messageExists : !messageExists);
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
    
    NSUInteger index = [self indexThatConformsToMessage:message
                                            withOptions:NSBinarySearchingInsertionIndex];
    return index;
}

- (NSUInteger)indexThatConformsToMessage:(QBChatMessage *)message withOptions:(NSBinarySearchingOptions)options {
    
    NSArray *messages = self.allMessages;
    NSUInteger index = [messages indexOfObject:message
                                 inSortedRange:(NSRange){0, [messages count]}
                                       options:options
                               usingComparator:messageComparator];
    return index;
}

- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message {
    
    NSIndexPath *indexPath = nil;
    
    NSUInteger indexOfObject = [self.allMessages indexOfObject:message];
    
    if (indexOfObject != NSNotFound) {
        indexPath = [NSIndexPath indexPathForItem:indexOfObject inSection:0];
    }
    
    return indexPath;
}

- (BOOL)hasMessages:(QBChatMessage *)messageToUpdate forUpdateType:(QMDataSourceActionType)updateType {
    
    NSDate *startDate = [messageToUpdate.dateSent dateAtStartOfDay];
    NSDate *endDate = [messageToUpdate.dateSent dateAtEndOfDay];
    
    NSPredicate *predicate;
    
    if (updateType == QMDataSourceActionTypeRemove) {
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

- (QBChatMessage *)handleMessage:(QBChatMessage *)message forUpdateType:(QMDataSourceActionType)updateType {
    
    if (message.isDateDividerMessage) {
        return nil;
    }
    
    NSDate *dateToAdd = [message.dateSent dateAtStartOfDay];
    
    if (updateType == QMDataSourceActionTypeAdd) {
        
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
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *chatMessage, NSDictionary<NSString *,id> *bindings) {
            return chatMessage.isDateDividerMessage && [chatMessage.dateSent isEqualToDate:dateToAdd];
        }];
        
        QBChatMessage *msg = [[self.allMessages filteredArrayUsingPredicate:predicate] firstObject];
        
        [self.dateDividers removeObject:dateToAdd];
        
        if (updateType == QMDataSourceActionTypeUpdate) {
            
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
