//
//  QMDeferredQueueManager.m
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDeferredQueueManager.h"
#import "QMDeferredQueueMemoryStorage.h"
#import "QMAsynchronousOperation.h"
#import "QMCancellableService.h"

@interface QMDeferredQueueManager()

@property (strong, nonatomic) QBMulticastDelegate <QMDeferredQueueManagerDelegate> *multicastDelegate;
@property (strong, nonatomic) QMDeferredQueueMemoryStorage *deferredQueueMemoryStorage;
@property (strong, nonatomic) NSOperationQueue *deferredOperationQueue;

@end

@implementation QMDeferredQueueManager

//MARK: - Life Cycle

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager {
    
    self = [super initWithServiceManager:serviceManager];
    
    if (self) {
        
        _deferredQueueMemoryStorage = [[QMDeferredQueueMemoryStorage alloc] init];
        _multicastDelegate = (id <QMDeferredQueueManagerDelegate>)[[QBMulticastDelegate alloc] init];
        _autoSendTimeInterval = 60 * 10; //10 minutes
        
        _maxDeferredActionsCount = 3;
        
        _deferredOperationQueue = [[NSOperationQueue alloc] init];
        _deferredOperationQueue.maxConcurrentOperationCount = 1;
        _deferredOperationQueue.name = @"QMServices.deferredOperationQueue";
        _deferredOperationQueue.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    }
    
    return self;
}

- (void)free {
    
    [_deferredQueueMemoryStorage free];
    [_deferredOperationQueue cancelAllOperations];
}

//MARK: - MulticastDelegate

- (void)addDelegate:(id)delegate {
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate {
    [self.multicastDelegate removeDelegate:delegate];
}

//MARK: - Messages

- (NSUInteger)numberOfNotSentMessagesForDialogWithID:(NSString *)dialogID {
    
    NSPredicate *predicate =
    [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *message,
                                          NSDictionary<NSString *,id> * bindings) {
        
        return [message.dialogID isEqualToString:dialogID] &&
        [self statusForMessage:message] == QMMessageStatusNotSent;
    }];
    
    NSArray<QBChatMessage *> *messages =
    [self.deferredQueueMemoryStorage.messages filteredArrayUsingPredicate:predicate];
    
    return messages.count;
}

- (NSArray<QBChatMessage *> *)messagesForDialogWithID:(NSString *)dialogID {
    
    NSPredicate *predicate =
    [NSPredicate predicateWithBlock:^BOOL(QBChatMessage *message,
                                          NSDictionary<NSString *,id> *bindings) {
        
        return [message.dialogID isEqualToString:dialogID];
    }];
    
    NSArray<QBChatMessage *> *messages =
    [self.deferredQueueMemoryStorage.messages filteredArrayUsingPredicate:predicate];
    
    return messages;
}

- (void)addOrUpdateMessage:(QBChatMessage *)message {
    
    BOOL messageIsExisted =
    [self.deferredQueueMemoryStorage containsMessage:message];
    
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
    [self.deferredOperationQueue cancelOperationWithID:message.ID];
}

- (QMMessageStatus)statusForMessage:(QBChatMessage *)message {
    
    if ([self.deferredQueueMemoryStorage containsMessage:message]) {
        
        return ([[QBChat instance] isConnected] &&
                [self isAutoSendAvailableForMessage:message]) ? QMMessageStatusSending : QMMessageStatusNotSent;
    }
    else {
        return QMMessageStatusSent;
    }
}

//MARK: - Deferred Queue Operations

- (void)perfromDefferedActionForMessage:(QBChatMessage *)message withCompletion:(QBChatCompletionBlock)completion {
    
    if ([_deferredOperationQueue hasOperationWithID:message.ID]) {
        return;
    }
    
    QMAsynchronousOperation *op =  [QMAsynchronousOperation asynchronousOperationWithID:message.ID];
    
    [op setAsyncOperationBlock:^(dispatch_block_t  _Nonnull finish) {
        __weak typeof(self) weakSelf = self;
        [self internalDefferedActionForMessage:message
                                withCompletion:^(NSError * _Nullable error) {
                                     if (completion) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(error);
                                    });
                                }
                                    if (!error) {
                                       __strong typeof(weakSelf) strongSelf = weakSelf;
                                         [strongSelf.deferredQueueMemoryStorage removeMessage:message];
                                    }
                                    
                                    finish();
                                }];
    }];
    
    [_deferredOperationQueue addOperation:op];
}

- (void)performDeferredActionsForDialogWithID:(NSString *)dialogID {
    
    NSArray<QBChatMessage *> *messages =
    [self messagesForDialogWithID:dialogID];
    
    for (QBChatMessage *message in messages) {
        if ([self isAutoSendAvailableForMessage:message]) {
            [self perfromDefferedActionForMessage:message withCompletion:nil];
        }
        else {
            continue;
        }
    }
}

- (void)performDeferredActions {
    
    
    for (QBChatMessage *message in self.deferredQueueMemoryStorage.messages) {
        [self perfromDefferedActionForMessage:message withCompletion:nil];
    }
}

- (void)internalDefferedActionForMessage:(QBChatMessage *)message
                          withCompletion:(QBChatCompletionBlock)completion {
    
    BOOL messageIsExisted = [self.deferredQueueMemoryStorage containsMessage:message];
    NSParameterAssert(messageIsExisted);
    
    if (messageIsExisted
        && [self.multicastDelegate respondsToSelector:@selector(deferredQueueManager:
                                                                performActionWithMessage:
                                                                withCompletion:)]) {
        
        [self.multicastDelegate deferredQueueManager:self
                            performActionWithMessage:message
                                      withCompletion:completion];
    }
}

//MARK: - Helpers

- (BOOL)isAutoSendAvailableForMessage:(QBChatMessage *)message {
    
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:message.dateSent];
    BOOL isAvailable = secondsBetween <= self.autoSendTimeInterval;
    return isAvailable;
}

- (BOOL)shouldSendMessagesInDialogWithID:(NSString *)dialogID {
    
    if ([[QBChat instance] isConnected] || self.maxDeferredActionsCount == 0) {
        return YES;
    }
    
    NSUInteger messagesCount = [self numberOfNotSentMessagesForDialogWithID:dialogID];
    return self.maxDeferredActionsCount > messagesCount;
}

//MARK: -
//MARK: QMMemoryTemporaryQueueDelegate

- (NSArray *)localMessagesForDialogWithID:(NSString *)dialogID {
    
    return [self messagesForDialogWithID:dialogID];
}

//MARK: -
//MARK: QMCancellableService

- (void)cancelOperationWithID:(NSString *)operationID {
    [_deferredOperationQueue cancelOperationWithID:operationID];
}

- (void)cancelAllOperations {
    [_deferredOperationQueue cancelAllOperations];
}


@end
