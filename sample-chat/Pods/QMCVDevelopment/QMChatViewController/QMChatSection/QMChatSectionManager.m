//
//  QMChatSectionManager.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 2/2/16.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "QMChatSectionManager.h"
#import "QMChatSection.h"
#import "QMChatDataSource.h"

@interface QMChatSectionManager ()

@property (strong, nonatomic) NSArray *chatSections;
@property (strong, nonatomic) NSMutableArray *editableSections;
@property (nonatomic) dispatch_queue_t serialQueue;
@property (strong, nonatomic) QMChatDataSource *chatDataSource;
@end

@implementation QMChatSectionManager

- (instancetype)initWithChatDataSource:(QMChatDataSource *)chatDataSource {
    
    self  = [super init];
    
    if (self) {
        _chatDataSource = chatDataSource;
    }
    
    return self;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _chatSections = [NSMutableArray array];
        _timeIntervalBetweenSections = 300.0f; // default time interval
        _animationEnabled = YES; // default animation value
        _serialQueue = dispatch_queue_create("com.q-municate.chatsectionmanager.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Add messages

- (void)addMessage:(QBChatMessage *)message {
    
    [self.chatDataSource addMessage:message];
}

- (void)addMessages:(NSArray *)messages {
    
    [self.chatDataSource addMessages:messages];
}

- (void)addMessage:(QBChatMessage *)message animated:(BOOL)animated {
    
    [self.chatDataSource addMessage:message];
}

- (void)addMessages:(NSArray *)messages animated:(BOOL)animated {
    [self.chatDataSource addMessages:messages];
}

#pragma mark - Update messages

- (void)updateMessage:(QBChatMessage *)message {
    
    [self.chatDataSource updateMessage:message];
}

- (void)updateMessages:(NSArray *)messages {
    
    [self.chatDataSource updateMessages:messages];
}

#pragma mark - Delete messages

- (void)deleteMessage:(QBChatMessage *)message {
    [self.chatDataSource deleteMessage:message];
}

- (void)deleteMessages:(NSArray *)messages {
    [self.chatDataSource deleteMessages:messages];
}

- (void)deleteMessage:(QBChatMessage *)message animated:(BOOL)animated {
    [self.chatDataSource deleteMessage:message];
}

- (void)deleteMessages:(NSArray *)messages animated:(BOOL)animated {
    [self.chatDataSource deleteMessages:messages];
 }

#pragma mark - Helpers

- (QMChatSection *)sectionThatCorrespondsToMessage:(QBChatMessage *)message {
    
    QMChatSection *firstSection = self.editableSections.firstObject;
    BOOL firstSectionDateIsNotDescending = [firstSection.lastMessageDate compare:message.dateSent] != NSOrderedDescending;
    
    if (firstSectionDateIsNotDescending) {
        // message is older then first message of first section
        
        if (fabs([message.dateSent timeIntervalSinceDate:firstSection.lastMessageDate]) > self.timeIntervalBetweenSections) {
            
            firstSection = [QMChatSection chatSection];
            [self.editableSections insertObject:firstSection atIndex:0];
        }
        
        return firstSection;
    }
    
    QMChatSection *lastSection = self.editableSections.lastObject;
    BOOL lastSectionDateIsNotAscending = [lastSection.firstMessageDate compare:message.dateSent] != NSOrderedAscending;
    
    if (lastSectionDateIsNotAscending) {
        // message is newer then last message of last section
        
        if (fabs([message.dateSent timeIntervalSinceDate:lastSection.firstMessageDate]) > self.timeIntervalBetweenSections) {
            
            lastSection = [QMChatSection chatSection];
            [self.editableSections addObject:lastSection];
        }
        
        return lastSection;
    }
    
    NSArray *chatSections = self.editableSections.copy;
    
    for (QMChatSection *chatSection in chatSections) {
        
        BOOL dateIsDescending = [chatSection.firstMessageDate compare:message.dateSent] == NSOrderedDescending;
        BOOL dateIsAscending = [chatSection.lastMessageDate compare:message.dateSent] == NSOrderedAscending;
        BOOL timeIntervalCheck = fabs([message.dateSent timeIntervalSinceDate:chatSection.firstMessageDate]) <= self.timeIntervalBetweenSections;
        
        if ((dateIsDescending
             && dateIsAscending)
            || timeIntervalCheck) {
            
            return chatSection;
        }
    }
    
    return nil;
}

- (QMChatSection *)createSectionWithMessage:(QBChatMessage *)message {
    
    NSInteger index = 0;
    QMChatSection *newSection = [QMChatSection chatSection];
    
    if (self.editableSections.count > 0) {
        
        // finding new section spot between all existent sections
        NSArray *chatSections = self.editableSections.copy;
        for (NSInteger i = 0; i < chatSections.count - 1; ++i) {
            
            QMChatSection *chatSection = chatSections[i];
            QMChatSection *nextChatSection = chatSections[i + 1];
            
            BOOL dateIsDescending = [chatSection.lastMessageDate compare:message.dateSent] == NSOrderedDescending;
            BOOL dateIsAscending = [nextChatSection.firstMessageDate compare:message.dateSent] == NSOrderedAscending;
            if (dateIsDescending
                && dateIsAscending) {
                
                index = i + 1;
                break;
            }
        }
    }
    
    [self.editableSections insertObject:newSection atIndex:index];
    
    return newSection;
}

#pragma mark - Getters

- (BOOL)isEmpty {
    
    return self.chatSections.count == 0;
}

- (NSInteger)chatSectionsCount {
    
    return self.chatSections.count;
}

- (NSInteger)messagesCountForSectionAtIndex:(NSInteger)sectionIndex {
    
    if (sectionIndex > self.chatSections.count - 1) {
        
        return NSNotFound;
    }
    
    QMChatSection *chatSection = self.chatSections[sectionIndex];
    
    return chatSection.messages.count;
}

- (QMChatSection *)chatSectionAtIndex:(NSInteger)sectionIndex {
    
    if (sectionIndex > self.chatSections.count - 1) {
        
        return nil;
    }
    
    return self.chatSections[sectionIndex];
}

- (NSUInteger)totalMessagesCount {
    
    return self.chatDataSource.messagesCount;
}

- (QBChatMessage *)messageForIndexPath:(NSIndexPath *)indexPath {
    
    return [self.chatDataSource messageForIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message {
    
    return [self.chatDataSource indexPathForMessage:message];
}

- (NSArray *)allMessages {
    
    return  self.chatDataSource.allMessages;
}

- (BOOL)messageExists:(QBChatMessage *)message {
    
    return [self.chatDataSource messageExists:message];
}

@end
