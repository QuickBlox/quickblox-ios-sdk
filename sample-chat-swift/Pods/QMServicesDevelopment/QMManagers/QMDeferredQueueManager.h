//
//  QMDeferredQueueManager.h
//  QMServices
//
//  Created by Vitaliy Gurkovsky on 8/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBMulticastDelegate.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@class BFTask;

@protocol QMDeferredQueueManagerDelegate;

typedef NS_ENUM(NSUInteger, QMMessageStatus) {
    QMMessageStatusSent = 0,
    QMMessageStatusSending,
    QMMessageStatusNotSent
};

@interface QMDeferredQueueManager : NSObject

@property (nonatomic, assign) NSTimeInterval autoSendTimeInterval;
@property (nonatomic, assign) NSUInteger maxDeferredActionsCount;

- (void)addDelegate:(id <QMDeferredQueueManagerDelegate>)delegate;
- (void)removeDelegate:(id <QMDeferredQueueManagerDelegate>)delegate;


- (void)addOrUpdateMessage:(QBChatMessage *)message;
- (void)removeMessage:(QBChatMessage *)message;

- (void)performDeferredActions;
- (void)performDeferredActionsForDialogWithID:(NSString *)dialogID;

- (void)perfromDefferedActionForMessage:(QBChatMessage *)message withCompletion:(nullable QBChatCompletionBlock)completion;

- (BFTask *)perfromDefferedActionForMessage:(QBChatMessage *)message;

- (QMMessageStatus)statusForMessage:(QBChatMessage *)message;

- (BOOL)shouldSendMessagesInDialogWithID:(NSString *)dialogID;

@end

@protocol QMDeferredQueueManagerDelegate <NSObject>

@optional

- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager performActionWithMessage:(QBChatMessage *)message withCompletion:(nullable QBChatCompletionBlock)completion;
- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager didAddMessageLocally:(QBChatMessage *)addedMessage;
- (void)deferredQueueManager:(QMDeferredQueueManager *)queueManager didUpdateMessageLocally:(QBChatMessage *)addedMessage;

@end

NS_ASSUME_NONNULL_END
