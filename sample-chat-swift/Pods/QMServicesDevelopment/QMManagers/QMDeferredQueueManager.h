//
//  QMDeferredQueueManager.h
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"

@protocol QMDeferredQueueManagerDelegate;
@protocol QMMemoryTemporaryQueueDelegate;


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMMessageStatus) {
    QMMessageStatusSent = 0,
    QMMessageStatusSending,
    QMMessageStatusNotSent
};

@interface QMDeferredQueueManager : QMBaseService <QMCancellableService>

@property (nonatomic, assign) NSTimeInterval autoSendTimeInterval;
@property (nonatomic, assign) NSUInteger maxDeferredActionsCount;

- (void)addDelegate:(id <QMDeferredQueueManagerDelegate>)delegate;
- (void)removeDelegate:(id <QMDeferredQueueManagerDelegate>)delegate;

- (void)addOrUpdateMessage:(QBChatMessage *)message;
- (void)removeMessage:(QBChatMessage *)message;

- (void)performDeferredActions;
- (void)performDeferredActionsForDialogWithID:(NSString *)dialogID;

- (void)perfromDefferedActionForMessage:(QBChatMessage *)message
                         withCompletion:(nullable QBChatCompletionBlock)completion;

- (QMMessageStatus)statusForMessage:(QBChatMessage *)message;

- (BOOL)shouldSendMessagesInDialogWithID:(NSString *)dialogID;

@end

@protocol QMDeferredQueueManagerDelegate <NSObject>

@optional

- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager
    performActionWithMessage:(QBChatMessage *)message
              withCompletion:(nullable QBChatCompletionBlock)completion;

- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager
        didAddMessageLocally:(QBChatMessage *)addedMessage;

- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager
     didUpdateMessageLocally:(QBChatMessage *)addedMessage;

- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager
      didUpdateMessageStatus:(QMMessageStatus)status
                     message:(QBChatMessage *)message;
@end

NS_ASSUME_NONNULL_END
