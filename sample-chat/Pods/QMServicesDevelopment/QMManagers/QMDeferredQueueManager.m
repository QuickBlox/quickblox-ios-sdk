//
//  QMDeferredQueueManager.m
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDeferredQueueManager.h"
#import "QMDeferredQueueMemoryStorage.h"
#import "QMServices.h"

@interface QMDeferredQueueManager()

@property (strong, nonatomic) QBMulticastDelegate <QMDeferredQueueManagerDelegate> *multicastDelegate;
@property (strong, nonatomic) QMDeferredQueueMemoryStorage *deferredQueueMemoryStorage;
@property (strong, nonatomic) NSMutableSet *performingMessages;
@end

@implementation QMDeferredQueueManager

#pragma mark - 
#pragma mark Life Cycle

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _deferredQueueMemoryStorage = [[QMDeferredQueueMemoryStorage alloc] init];
        _multicastDelegate = (id <QMDeferredQueueManagerDelegate>)[[QBMulticastDelegate alloc] init];
        _autoSendTimeInterval = 60;
        _performingMessages = [NSMutableSet set];
        _maxDeferredActionsCount = 3;
    }

    return self;
}

- (void)dealloc {
    
}

#pragma mark -
#pragma mark MulticastDelegate

- (void)addDelegate:(id)delegate {
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate {
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark -
#pragma mark Messages

- (NSUInteger)numberOfNotSentMessagesForDialogWithID:(NSString *)dialogID {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage * _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [message.dialogID isEqualToString:dialogID] && [self statusForMessage:message] == QMMessageStatusNotSent;
    }];
    
    NSArray *messages = [self.deferredQueueMemoryStorage.messages filteredArrayUsingPredicate:predicate];
    
    return messages.count;
}

- (NSArray *)messagesForDialogWithID:(NSString *)dialogID {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatMessage * _Nonnull message, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [message.dialogID isEqualToString:dialogID];
    }];
    
    NSArray *messages = [self.deferredQueueMemoryStorage.messages filteredArrayUsingPredicate:predicate];
    
    return messages;
}

- (void)addOrUpdateMessage:(QBChatMessage *)message {
    
    BOOL messageIsExisted = [self.deferredQueueMemoryStorage containsMessage:message];
    
    [self.deferredQueueMemoryStorage addMessage:message];
    
    if (!messageIsExisted) {
        
        if ([self.multicastDelegate respondsToSelector:@selector(deferredQueueManager:didAddMessageLocally:)]) {
            
            [self.multicastDelegate deferredQueueManager:self
                                    didAddMessageLocally:message];
        }
    }
    else {
        if ([self.multicastDelegate respondsToSelector:@selector(deferredQueueManager:didUpdateMessageLocally:)]) {
            
            [self.multicastDelegate deferredQueueManager:self
                                    didUpdateMessageLocally:message];
        }
    }
}

- (void)removeMessage:(QBChatMessage *)message {
    
    [self.deferredQueueMemoryStorage removeMessage:message];
    [self.performingMessages removeObject:message.ID];
}

- (QMMessageStatus)statusForMessage:(QBChatMessage *)message {
    
    if ([self.deferredQueueMemoryStorage containsMessage:message]) {
        
        return ([[QBChat instance] isConnected] && [self isAutoSendAvailableForMessage:message]) ? QMMessageStatusSending : QMMessageStatusNotSent;
    }
    else {
        return QMMessageStatusSent;
    }
}

#pragma mark -
#pragma mark Deferred Queue Operations

- (BFTask *)perfromDefferedActionForMessage:(QBChatMessage *)message {
    
    if ([self.performingMessages containsObject:message.ID]) {
        return nil;
    }
    
    [self.performingMessages addObject:message.ID];
    
    BFTaskCompletionSource *successful = [BFTaskCompletionSource taskCompletionSource];
    
    [self perfromDefferedActionForMessage:message withCompletion:^(NSError * _Nullable error) {
        
        [self.performingMessages removeObject:message.ID];
        
        if (error != nil) {
            [successful setError:error];
        }
        else {
            [successful setResult:nil];
        }
    }];
    
    return successful.task;
}

- (void)performDeferredActionsForDialogWithID:(NSString *)dialogID {
    
    NSArray *messages = [self messagesForDialogWithID:dialogID];
    if (messages.count == 0) {
        return;
    }
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (QBChatMessage *message in messages) {
        
        if ([self isAutoSendAvailableForMessage:message]) {
            
            task = [task continueWithBlock:^id(BFTask *task) {
                return [self perfromDefferedActionForMessage:message];
            }];
        }
        else {
            continue;
        }
    }
}

- (void)performDeferredActions {
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (QBChatMessage *message in self.deferredQueueMemoryStorage.messages) {
        
        task = [task continueWithBlock:^id(BFTask *task) {
            return [self perfromDefferedActionForMessage:message];
        }];
    }
}


- (void)perfromDefferedActionForMessage:(QBChatMessage *)message withCompletion:(QBChatCompletionBlock)completion {
    
    BOOL messageIsExisted = [self.deferredQueueMemoryStorage containsMessage:message];
    
    if (messageIsExisted
        && [self.multicastDelegate respondsToSelector:@selector(deferredQueueManager:
                                                                performActionWithMessage:
                                                                withCompletion:)]) {
        
        [self.multicastDelegate deferredQueueManager:self
                            performActionWithMessage:message
                                      withCompletion:completion];
    }
}

#pragma mark -
#pragma mark Helpers

- (BOOL)isAutoSendAvailableForMessage:(QBChatMessage *)message {

    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:message.dateSent];

    return secondsBetween <= self.autoSendTimeInterval;
}

- (BOOL)shouldSendMessagesInDialogWithID:(NSString *)dialogID {
    
    if ([[QBChat instance] isConnected] || self.maxDeferredActionsCount == 0) {
        return YES;
    }
    
    NSUInteger messagesCount = [self numberOfNotSentMessagesForDialogWithID:dialogID];
    return self.maxDeferredActionsCount > messagesCount;
    
}

#pragma mark -
#pragma mark QMMemoryTemporaryQueueDelegate

- (NSArray *)localMessagesForDialogWithID:(NSString *)dialogID {
    
    return [self messagesForDialogWithID:dialogID];
}

@end
