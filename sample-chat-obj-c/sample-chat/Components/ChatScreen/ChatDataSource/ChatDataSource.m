//
//  ChatDataSource.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatDataSource.h"
#import "QBChatMessage+QBDateDivider.h"
#import "NSDate+ChatDataSource.h"
#import "DateUtils.h"

NSString *const dateDividerKey = @"kQBDateDividerCustomParameterKey";

@interface ChatDataSource()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableSet *dateDividers;
@property (strong, nonatomic) dispatch_queue_t serialQueue;

@end

@implementation ChatDataSource

NSComparator messageComparator = ^(QBChatMessage *obj1, QBChatMessage *obj2) {
    
    NSComparisonResult result = [obj2.dateSent compareWithDate:obj1.dateSent];
    
    if (result != NSOrderedSame) {
        return result;
    } else {
        
        if (obj1.isDateDividerMessage) {
            return NSOrderedDescending;
        } else if (obj2.isDateDividerMessage) {
            return NSOrderedAscending;
        } else {
            NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:NO];
            NSComparisonResult idResult =  [desc compareObject:obj1 toObject:obj2];
            return idResult;
        }
    }
};

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    
    if (self) {
        _serialQueue = dispatch_queue_create("com.chatvc.datasource.queue", DISPATCH_QUEUE_SERIAL);
        _dateDividers = [NSMutableSet set];
        _messages = [NSMutableArray array];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\t messages: %@", [super description], self.allMessages];
}

// MARK: - Public Methods
// MARK: - Adding
- (void)addMessage:(QBChatMessage *)message {
    [self addMessages:@[message]];
}


- (void)addMessages:(NSArray<QBChatMessage *> *)messages {
    
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        NSEnumerator *enumerator = [messages objectEnumerator];
        
        NSSortDescriptor *dateSentDescriptor =
        [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES];
        NSSortDescriptor *idDescriptor =
        [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
        enumerator = [[messages sortedArrayUsingDescriptors:@[dateSentDescriptor, idDescriptor]] objectEnumerator];
        
        for (QBChatMessage *message in enumerator) {
            
            NSAssert(message.dateSent != nil, @"Message must have dateSent!");
            
            if ([self isExistMessage:message] || message.isDateDividerMessage) {
                continue;
            }
            [messagesArray addObject:message];
            
            NSDate *divideDate = [message.dateSent dateAtStartOfDay];
            
            if ([self.dateDividers containsObject:divideDate]) {
                continue;
            }
            
            [self.dateDividers addObject:divideDate];
            
            QBChatMessage *dividerMessage = [QBChatMessage new];
            dividerMessage.text = [DateUtils formattedLastSeenString:divideDate withTimePrefix:nil];
            dividerMessage.dateSent = divideDate;
            dividerMessage.isDateDividerMessage = YES;
            
            if (dividerMessage != nil) {
                [messagesArray addObject:dividerMessage];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (messagesArray.count) {
                [self.delegate chatDataSource:self changeWithMessages:messagesArray action:DataSourceActionTypeAdd];
            }
        });
    });
}

// MARK: - Removing
- (void)deleteMessage:(QBChatMessage *)message {
    [self deleteMessages:@[message]];
}

- (void)deleteMessages:(NSArray<QBChatMessage *> *)messages {
    
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *messageIDs = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        NSEnumerator *enumerator = [messages objectEnumerator];
        
        for (QBChatMessage *message in enumerator) {
            NSAssert(message.dateSent != nil, @"Message must have dateSent!");
            if (message.dateSent == nil || ![self isExistMessage:message] || message.isDateDividerMessage) {
                continue;
            }
            [messagesArray addObject:message];
            
            QBChatMessage *dividerMessage = nil;
            NSDate *startDate = nil;
            NSDate *endDate = nil;
            startDate = [message.dateSent dateAtStartOfDay];
            endDate = [message.dateSent dateAtEndOfDay];
            
            if (startDate == nil || endDate == nil) {
                // there is no date divider for this message
                // such case should not occure, but safe check
                continue;
            }
            
            NSPredicate *currentDayMessagesPredicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage * _Nonnull msg, NSDictionary<NSString *,id> * _Nullable bindings) {
                return !msg.isDateDividerMessage && [msg.dateSent isBetweenStartDate:startDate andEndDate:endDate respectOrderedSame:YES] && msg.ID != message.ID;
            }];
            
            NSArray *currentDayMessages = [self.allMessages filteredArrayUsingPredicate:currentDayMessagesPredicate];
            if (!currentDayMessages) {
                return;
            }
            
            BOOL needAddDividerMessage = currentDayMessages.count == 2;
            if (needAddDividerMessage == NO) {
                continue;
            }
            
            NSDate *divideDate = [message.dateSent dateAtStartOfDay];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *chatMessage, NSDictionary<NSString *,id> *bindings) {
                return chatMessage.isDateDividerMessage && [chatMessage.dateSent isEqualToDate:divideDate];
            }];
            
            QBChatMessage *msg = [[self.allMessages filteredArrayUsingPredicate:predicate] firstObject];
            if (divideDate == nil) {
                return;
            }
            [self.dateDividers removeObject:divideDate];
            dividerMessage = msg;
            
            if (dividerMessage != nil) {
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
                [self.delegate chatDataSource:self changeWithMessages:messagesArray action:DataSourceActionTypeRemove];
            }
        });
    });
}

// MARK: - Updating
- (void)updateMessage:(QBChatMessage *)message {
    if (message) {
        [self updateMessages:@[message]];
    }
}

- (void)updateMessages:(NSArray<QBChatMessage *> *)messages {
    dispatch_async(_serialQueue, ^{
        
        NSMutableArray *messageIDs = [NSMutableArray arrayWithCapacity:messages.count];
        NSMutableArray *messagesArray = [NSMutableArray arrayWithCapacity:messages.count];
        NSEnumerator *enumerator = [messages objectEnumerator];
        
        for (QBChatMessage *message in enumerator) {
            
            NSAssert(message.dateSent != nil, @"Message must have dateSent!");
            
            if (message.dateSent == nil || ![self isExistMessage:message] || message.isDateDividerMessage) {
                continue;
            }
            
            NSIndexPath *indexPath = [self messageIndexPath:message];
            NSUInteger updatedMessageIndex = [self indexThatConformsToMessage:message];
            
            if (updatedMessageIndex != indexPath.item) {
                [self deleteMessage:message];
                [self addMessage:message];
                return;
            } else {
                [messagesArray addObject:message];
            }
            [messageIDs addObject:message.ID];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (messageIDs.count > 0) {
                [self.delegate chatDataSource:self willBeChangedWithMessageIDs:messageIDs];
            }
            if (messagesArray.count > 0) {
                [self.delegate chatDataSource:self changeWithMessages:messagesArray action:DataSourceActionTypeUpdate];
            }
        });
    });
}

// MARK: - Data Source
- (NSArray *)performChangesWithMessages:(NSArray *)messages updateType:(DataSourceActionType)updateType {
    NSArray *indexPaths = [NSMutableArray arrayWithCapacity:messages.count];
    
    if (updateType == DataSourceActionTypeRemove) {
        indexPaths = [self indexPathsForMessages:messages];
    }
    
    for (QBChatMessage *msg in messages) {
        if (updateType == DataSourceActionTypeAdd) {
            [self insertMessage:msg];
        } else if (updateType == DataSourceActionTypeUpdate) {
            self.messages[[self messageIndexPath:msg].item] = msg;
        } else if (DataSourceActionTypeRemove) {
            [self.messages removeObjectAtIndex:[self messageIndexPath:msg].item];
        }
    }
    
    if (updateType == DataSourceActionTypeAdd || updateType == DataSourceActionTypeUpdate) {
        indexPaths = [self indexPathsForMessages:messages];
    }
    
    return indexPaths;
}

// MARK: - Clear
- (void)clear {
    [self.messages removeAllObjects];
}


// MARK: - Helpers
- (NSArray *)indexPathsForMessages:(NSArray *)messages {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (QBChatMessage *msg in messages) {
        NSIndexPath *indexPath = [self messageIndexPath:msg];
        if (indexPath) {
            [indexPaths addObject:indexPath];
        }
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

- (NSInteger)loadMessagesCount {
    NSArray *allMessages = [self allMessages];
    NSMutableArray *loadMessages = [NSMutableArray arrayWithArray:[self allMessages]];
    
    for (QBChatMessage *message in allMessages) {
        if (message.isDateDividerMessage) {
            [loadMessages removeObject:message];
        }
    }
    return allMessages.count;
}

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

- (QBChatMessage *)messageWithID:(NSString *)ID {
    NSArray *allMessages = [self allMessages];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", ID];
    QBChatMessage *message = [[allMessages filteredArrayUsingPredicate:predicate] firstObject];
    if (message) {
        return message;
    }
    return nil;
}

- (QBChatMessage *)messageWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == NSNotFound) {
        return nil;
    }
    
    return self.allMessages[indexPath.item];
}


- (BOOL)isExistMessage:(QBChatMessage *)message {
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

- (NSIndexPath *)messageIndexPath:(QBChatMessage *)message {
    NSIndexPath *indexPath = nil;
    NSUInteger indexOfObject = [self.allMessages indexOfObject:message];
    
    if (indexOfObject != NSNotFound) {
        indexPath = [NSIndexPath indexPathForItem:indexOfObject inSection:0];
    }
    
    return indexPath;
}

#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    
    return [_messages countByEnumeratingWithState:state objects:buffer count:len];
}

@end

