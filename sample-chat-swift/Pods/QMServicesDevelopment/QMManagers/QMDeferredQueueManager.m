//
//  QMDeferredQueueManager.m
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDeferredQueueManager.h"
#import "QMDeferredQueueMemoryStorage.h"

@interface QMDeferredQueueManager()

@property (strong, nonatomic) QBMulticastDelegate <QMDeferredQueueManagerDelegate> *multicastDelegate;
@property (strong, nonatomic) QMDeferredQueueMemoryStorage *deferredQueueMemoryStorage;
@end

@implementation QMDeferredQueueManager

#pragma mark - 
#pragma mark Life Cycle

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _deferredQueueMemoryStorage = [[QMDeferredQueueMemoryStorage alloc] init];
        _multicastDelegate = [[QBMulticastDelegate alloc] init];
    }

    return self;
}

- (void)dealloc {
    
}

#pragma mark -
#pragma mark MulticastDelegate

- (void)addDelegate:(QB_NONNULL id <QMDeferredQueueManagerDelegate>)delegate {
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(QB_NONNULL id <QMDeferredQueueManagerDelegate>)delegate {
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark -
#pragma mark Messages

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
    
}

- (QMMessageStatus)statusForMessage:(QBChatMessage *)message {
    
    if ([self.deferredQueueMemoryStorage containsMessage:message]) {
        return [[QBChat instance] isConnected] ? QMMessageStatusSending : QMMessageStatusNotSent;
    }
    else {
        return QMMessageStatusSent;
    }
}

#pragma mark -
#pragma mark Deferred Queue Operations

- (BFTask *)perfromDefferedActionForMessage:(QBChatMessage*)message {
    
    BFTaskCompletionSource *successful = [BFTaskCompletionSource taskCompletionSource];
    
    [self perfromDefferedActionForMessage:message withCompletion:^(NSError * _Nullable error) {
        
        if (error) {
            [successful setError:error];
        }
        else {
            [successful setResult:message];
        }
    }];
    
    return successful.task;
}

- (void)performDeferredActionsForDialogWithID:(NSString *)dialogID {
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (QBChatMessage *message in [self messagesForDialogWithID:dialogID]) {
        
        task = [task continueWithBlock:^id(BFTask *task) {
            return [self perfromDefferedActionForMessage:message];
        }];
    }
    
    [task continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        return nil;
    }];
}

- (void)performDeferredActions {
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (QBChatMessage *message in self.deferredQueueMemoryStorage.messages) {
        
        task = [task continueWithBlock:^id(BFTask *task) {
            return [self perfromDefferedActionForMessage:message];
        }];
    }
    
    [task continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        return nil;
    }];
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

#pragma mark
#pragma mark QMMemoryTemporaryQueueDelegate

- (NSArray *)localMessagesForDialogWithID:(NSString *)dialogID {
    
    return [self messagesForDialogWithID:dialogID];
}

@end
