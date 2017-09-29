//
//  QMChatDataSource.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "NSDate+ChatDataSource.h"
#import "QMDateUtils.h"

@interface QMChatDataSource()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableSet *dateDividers;
@property (strong, nonatomic) dispatch_queue_t serialQueue;

@end

@implementation QMChatDataSource

NSComparator messageComparator = ^(QBChatMessage *obj1, QBChatMessage *obj2) {
    
    NSComparisonResult result = [obj2.dateSent compareWithDate:obj1.dateSent];
    
    if (result != NSOrderedSame) {
        return result;
    }
    else {
        
        if (obj1.isDateDividerMessage) {
            return NSOrderedDescending;
        }
        else if (obj2.isDateDividerMessage) {
            return NSOrderedAscending;
        }
        else {
            NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:NO];
            NSComparisonResult idResult =  [desc compareObject:obj1 toObject:obj2];
            return idResult;
        }
    }
};

// MARK: - Initialization

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _serialQueue = dispatch_queue_create("com.qmchatvc.datasource.queue", DISPATCH_QUEUE_SERIAL);
        
        _dateDividers = [NSMutableSet set];
        _messages = [NSMutableArray array];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\t messages: %@", [super description], self.allMessages];
}

// MARK: - Adding

- (void)addMessage:(QBChatMessage *)message {
    [self addMessages:@[message]];
}

- (void)addMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeAdd];
}

// MARK: - Removing

- (void)deleteMessage:(QBChatMessage *)message {
    [self deleteMessages:@[message]];
}

- (void)deleteMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeRemove];
}

// MARK: - Updating

- (void)updateMessage:(QBChatMessage *)message {
    [self updateMessages:@[message]];
}

- (void)updateMessages:(NSArray<QBChatMessage *> *)messages {
    [self changeDataSourceWithMessages:messages forUpdateType:QMDataSourceActionTypeUpdate];
}

// MARK: - Data Source

- (void)changeDataSourceWithMessages:(NSArray *)messages forUpdateType:(QMDataSourceActionType)updateType {
    
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *messageIDs = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        NSEnumerator *enumerator = [messages objectEnumerator];
        if (_customDividerInterval > 0
            && updateType == QMDataSourceActionTypeAdd) {
            NSSortDescriptor *dateSentDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateSent"
                                                                                 ascending:YES];
            NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ID"
                                                                           ascending:YES];
            enumerator = [[messages sortedArrayUsingDescriptors:@[dateSentDescriptor, idDescriptor]] objectEnumerator];
        }
        for (QBChatMessage *message in enumerator) {
            
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
            
            QBChatMessage *dividerMessage = nil;
            NSDate *removedDivider = nil;
            [self handleMessage:message forUpdateType:updateType dividerMessage:&dividerMessage removedDivider:&removedDivider];
            if (dividerMessage != nil) {
                [messagesArray addObject:dividerMessage];
                [messageIDs addObject:dividerMessage.ID];
            }
            if (removedDivider != nil) {
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *chatMessage, NSDictionary<NSString *,id> *bindings) {
                    return chatMessage.isDateDividerMessage && [chatMessage.dateSent isEqualToDate:removedDivider];
                }];
                
                QBChatMessage *msg = [[messagesArray filteredArrayUsingPredicate:predicate] firstObject];
                
                [messagesArray removeObject:msg];
                [messageIDs removeObject:msg.ID];
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

// MARK: - Helpers

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

// MARK: - Date Dividers

- (NSDate *)appropriateDividerForMessageDate:(NSDate *)messageDate {
    NSDate *dividerDate = nil;
    NSEnumerator *enumerator = [[self.dateDividers copy] objectEnumerator];
    for (NSDate *date in enumerator) {
        NSComparisonResult comparisonResult = [messageDate compareWithDate:date];
        if (comparisonResult == NSOrderedDescending) {
            NSDate *rangedDate = [date dateByAddingTimeInterval:(_customDividerInterval-1)];
            if ([messageDate isBetweenStartDate:date andEndDate:rangedDate respectOrderedSame:YES]) {
                dividerDate = date;
                break;
            }
        }
        else if (comparisonResult == NSOrderedSame) {
            dividerDate = date;
            break;
        }
    }
    return dividerDate;
}

- (BOOL)hasMessages:(QBChatMessage *)messageToUpdate forUpdateType:(QMDataSourceActionType)updateType {
    
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    
    if (_customDividerInterval > 0) {
        startDate = [self appropriateDividerForMessageDate:messageToUpdate.dateSent];
        endDate = [startDate dateByAddingTimeInterval:(_customDividerInterval)];
    }
    else {
        startDate = [messageToUpdate.dateSent dateAtStartOfDay];
        endDate = [messageToUpdate.dateSent dateAtEndOfDay];
    }
    
    if (startDate == nil || endDate == nil) {
        // there is no date divider for this message
        // such case should not occure, but safe check
        return NO;
    }
    
    NSPredicate *predicate = nil;
    if (updateType == QMDataSourceActionTypeRemove) {
        predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage * _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
            return !message.isDateDividerMessage && [message.dateSent isBetweenStartDate:startDate andEndDate:endDate respectOrderedSame:YES] && message.ID != messageToUpdate.ID;
        }];
    }
    else {
        predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage * _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
            return !message.isDateDividerMessage && [message.dateSent isBetweenStartDate:startDate andEndDate:endDate respectOrderedSame:YES];
        }];
    }
    
    NSArray *messages = [self.allMessages filteredArrayUsingPredicate:predicate];
    
    return messages.count > 0;
}

static inline QBChatMessage *dateDividerMessage(NSDate *date, BOOL isCustom) {
    QBChatMessage *dividerMessage = [QBChatMessage new];
    dividerMessage.text = isCustom ? [QMDateUtils formattedLastSeenString:date withTimePrefix:nil] : [QMDateUtils formattedStringFromDate:date];
    dividerMessage.dateSent = date;
    dividerMessage.isDateDividerMessage = YES;
    return dividerMessage;
}

- (void)handleMessage:(QBChatMessage *)message forUpdateType:(QMDataSourceActionType)updateType dividerMessage:(QBChatMessage **)dividerMessage removedDivider:(NSDate **)removedDivider {
    
    if (message.isDateDividerMessage) {
        return;
    }
    
    if (updateType == QMDataSourceActionTypeAdd) {
        
        NSDate *divideDate = _customDividerInterval > 0 ? message.dateSent : [message.dateSent dateAtStartOfDay];
        if (_customDividerInterval > 0) {
            
            BOOL belongsToExistentDividers = NO;
            NSDate *removeDate = nil;
            NSEnumerator *enumerator = [[self.dateDividers copy] objectEnumerator];
            for (NSDate *date in enumerator) {
                NSComparisonResult comparisonResult = [message.dateSent compareWithDate:date];
                if (comparisonResult > NSOrderedAscending) {
                    NSDate *rangedDate = [date dateByAddingTimeInterval:(_customDividerInterval)];
                    if ((comparisonResult == NSOrderedSame) || [message.dateSent isBetweenStartDate:date andEndDate:rangedDate respectOrderedSame:NO]) {
                        belongsToExistentDividers = YES;
                        break;
                    }
                }
            }
            
            if (!belongsToExistentDividers) {
                
                if (removeDate != nil) {
                    [self.dateDividers removeObject:removeDate];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *chatMessage, NSDictionary<NSString *,id> *bindings) {
                        return chatMessage.isDateDividerMessage && [chatMessage.dateSent isEqualToDate:removeDate];
                    }];
                    QBChatMessage *msg = [[self.allMessages filteredArrayUsingPredicate:predicate] firstObject];
                    
                    if (msg != nil) {
                        [self deleteMessage:msg];
                    }
                    else {
                        *removedDivider = removeDate;
                    }
                }
                
                [self.dateDividers addObject:divideDate];
                *dividerMessage = dateDividerMessage(divideDate, YES);
            }
        }
        else {
            if ([self.dateDividers containsObject:divideDate]) {
                return;
            }
            
            [self.dateDividers addObject:divideDate];
            *dividerMessage = dateDividerMessage(divideDate, NO);
        }
    }
    else {
        
        BOOL hasMessages = [self hasMessages:message forUpdateType:updateType];
        if (hasMessages) {
            return;
        }
        
        NSDate *divideDate = _customDividerInterval > 0 ? [self appropriateDividerForMessageDate:message.dateSent] : [message.dateSent dateAtStartOfDay];
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *chatMessage, NSDictionary<NSString *,id> *bindings) {
            return chatMessage.isDateDividerMessage && [chatMessage.dateSent isEqualToDate:divideDate];
        }];
        
        QBChatMessage *msg = [[self.allMessages filteredArrayUsingPredicate:predicate] firstObject];
        
        if (divideDate == nil) {
            return;
        }
        
        [self.dateDividers removeObject:divideDate];
        
        if (updateType == QMDataSourceActionTypeUpdate) {
            [self deleteMessage:msg];
        }
        else {
            *dividerMessage = msg;
        }
    }
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    
    return [_messages countByEnumeratingWithState:state objects:buffer count:len];
}

@end
