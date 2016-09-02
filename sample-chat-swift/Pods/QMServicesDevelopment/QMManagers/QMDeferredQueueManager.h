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

@protocol QMDeferredQueueManagerDelegate;

typedef NS_ENUM(NSUInteger, QMMessageStatus) {
    QMMessageStatusSent = 0,
    QMMessageStatusSending,
    QMMessageStatusNotSent
};

@interface QMDeferredQueueManager : NSObject

@property (nonatomic,assign) NSTimeInterval autoSendTimeInterval;

- (void)addDelegate:(QB_NONNULL id <QMDeferredQueueManagerDelegate>)delegate;
- (void)removeDelegate:(QB_NONNULL id <QMDeferredQueueManagerDelegate>)delegate;


- (void)addOrUpdateMessage:(QB_NONNULL QBChatMessage *)message;
- (void)removeMessage:(QB_NONNULL QBChatMessage *)message;

- (void)performDeferredActions;
- (void)performDeferredActionsForDialogWithID:(QB_NONNULL NSString *)dialogID;

- (void)perfromDefferedActionForMessage:(QB_NONNULL QBChatMessage *)message withCompletion:(QB_NULLABLE_S QBChatCompletionBlock)completion;

- (QB_NONNULL BFTask *)perfromDefferedActionForMessage:(QB_NONNULL QBChatMessage *)message;

- (QMMessageStatus)statusForMessage:(QB_NONNULL QBChatMessage *)message;

@end

@protocol QMDeferredQueueManagerDelegate <NSObject>

@optional

- (void)deferredQueueManager:(QB_NONNULL QMDeferredQueueManager *)queueManager performActionWithMessage:(QB_NONNULL QBChatMessage *)message withCompletion:(QB_NULLABLE_S QBChatCompletionBlock)completion;
- (void)deferredQueueManager:(QB_NONNULL QMDeferredQueueManager *)queueManager didAddMessageLocally:(QB_NONNULL QBChatMessage *)addedMessage;
- (void)deferredQueueManager:(QB_NONNULL QMDeferredQueueManager *)queueManager didUpdateMessageLocally:(QB_NONNULL QBChatMessage *)addedMessage;

@end

