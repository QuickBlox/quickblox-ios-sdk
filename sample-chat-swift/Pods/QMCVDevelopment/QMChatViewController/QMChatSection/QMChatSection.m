//
//  QMChatSection.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "QMChatSection.h"
#import <Quickblox/Quickblox.h>

@implementation QMChatSection

#pragma mark - Class methods

- (instancetype)init {
    
    if (self = [super init]) {
        
        _messages = [NSMutableArray array];
    }
    
    return self;
}

- (instancetype)initWithMessage:(QBChatMessage *)message {
    
    if (self = [super init]) {
        
        _messages = [NSMutableArray arrayWithObject:message];
    }
    
    return self;
}

+ (QMChatSection *)chatSection {
    
    return [[self alloc] init];
}

+ (QMChatSection *)chatSectionWithMessage:(QBChatMessage *)message {
    
    return [[self alloc] initWithMessage:message];
}

#pragma mark - Instance methods

- (NSUInteger)insertMessage:(QBChatMessage *)message {
    
    NSUInteger index = [self indexThatConformsToMessage:message];
    [self.messages insertObject:message atIndex:index];
    
    return index;
}

- (NSUInteger)indexThatConformsToMessage:(QBChatMessage *)message {
    
    NSUInteger index = self.messages.count;
    
    
    NSArray *messages = self.messages.copy;
    
    for (QBChatMessage *message_t in messages) {
        
        // server date value is always int
        BOOL dateIsNotAscending = (NSInteger)[message.dateSent timeIntervalSinceDate:message_t.dateSent] >= 0;
        if (dateIsNotAscending) {
            
            index = [messages indexOfObject:message_t];
            break;
        }
    }
    
    return index;
}

#pragma mark - Getters

- (BOOL)isEmpty {
    
    return self.messages.count == 0;
}

- (NSDate *)firstMessageDate {
    
    QBChatMessage *firstMessage = self.messages.firstObject;
    return firstMessage.dateSent;
}

- (NSDate *)lastMessageDate {
    
    QBChatMessage *lastMessage = self.messages.lastObject;
    return lastMessage.dateSent;
}

@end
