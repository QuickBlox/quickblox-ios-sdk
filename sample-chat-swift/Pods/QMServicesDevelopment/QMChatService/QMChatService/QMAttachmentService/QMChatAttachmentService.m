//
//  QMChatAttachmentService.m
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatAttachmentService.h"

#import "QMChatService.h"
#import "QMMediaBlocks.h"
#import "QBChatMessage+QMCustomParameters.h"

#import "QBChatAttachment+QMCustomParameters.h"
#import "QBChatAttachment+QMFactory.h"

#import "QMSLog.h"

@implementation QMAttachmentOperation

- (void)setCancelBlock:(dispatch_block_t)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil; // don't forget to nil the cancelBlock, otherwise we will get crashes
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    
    [super cancel];
    
    if (self.cancelBlock) {
        self.cancelBlock();
        _cancelBlock = nil;
    }
}

@end

@interface QMChatAttachmentService() <QMAttachmentContentServiceDelegate>

@property (nonatomic, strong) QBMulticastDelegate <QMChatAttachmentServiceDelegate> *multicastDelegate;

@property (nonatomic, strong) NSMutableDictionary *attachmentsStorage;
@property (nonatomic, strong) NSMutableDictionary *attachmentsStates;
@property (nonatomic, strong) NSMutableDictionary *runningOperations;

@end

@implementation QMChatAttachmentService

- (instancetype)initWithStoreService:(QMAttachmentStoreService *)storeService
                      contentService:(QMAttachmentContentService *)contentService
                        assetService:(QMAttachmentAssetService *)assetService {
    
    if (self = [super init]) {
        
        _storeService = storeService;
        _contentService = contentService;
        _assetService = assetService;
        
        _multicastDelegate = (id <QMChatAttachmentServiceDelegate>)[[QBMulticastDelegate alloc] init];
        _attachmentsStates = [NSMutableDictionary dictionary];
        _runningOperations = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)prepareAttachment:(QBChatAttachment *)attachment
                  message:(QBChatMessage *)message
               completion:(QMAttachmentAssetLoaderCompletionBlock)completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusPreparing
                             forMessage:message];
    
    [self.assetService loadAssetForAttachment:attachment
                                    messageID:message.ID
                                   completion:^(UIImage * _Nullable image,
                                                Float64 durationInSeconds,
                                                CGSize size,
                                                NSError * _Nullable error,
                                                BOOL cancelled)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             QMMessageAttachmentStatus status;
             
             if (cancelled) {
                 status = QMMessageAttachmentStatusNotLoaded;
             }
             else if (error) {
                 status = QMMessageAttachmentStatusError;
             }
             else {
                 status = QMMessageAttachmentStatusLoaded;
             }
             
             __strong typeof(weakSelf) strongSelf = weakSelf;
             [strongSelf changeMessageAttachmentStatus:status
                                            forMessage:message];
             
             if (completion && !cancelled) {
                 completion(image,
                            durationInSeconds,
                            size,
                            error,
                            cancelled);
             }
         });
     }];
}

- (void)cancelOperationsWithMessageID:(NSString *)messageID {
    
    QMAttachmentOperation *operation = nil;
    @synchronized (self.runningOperations) {
        operation = self.runningOperations [messageID];
    }
    if (!operation) {
        QMSLog(@"NO OPERATION FOR CALL CANCELL ID: %@", messageID);
    }
    [operation cancel];
    
}

- (void)imageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                       completion:(void(^)(NSError *error, UIImage *image))completion {
    
    QBChatAttachment *attachment = [attachmentMessage.attachments firstObject];
    [self attachmentWithID:attachment.ID
                   message:attachmentMessage
             progressBlock:nil
                completion:^(QMAttachmentOperation * _Nonnull op)
     {
         completion(op.error, op.attachment.image);
     }];
}

- (void)localImageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                            completion:(void(^)(UIImage *image))completion {
    
    QBChatAttachment *attachment = [attachmentMessage.attachments firstObject];
    [self.storeService cachedImageForAttachment:attachment
                                      messageID:attachmentMessage.ID
                                       dialogID:attachmentMessage.dialogID
                                     completion:^(UIImage *image) {
                                         if (completion) {
                                             completion(image);
                                         }
                                     }];
}


- (BOOL)attachmentIsReadyToPlay:(QBChatAttachment *)attachment
                        message:(QBChatMessage *)message {
    
    if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
        
        NSURL *fileURL = [self.storeService fileURLForAttachment:attachment
                                                       messageID:message.ID
                                                        dialogID:message.dialogID];
        return fileURL != nil;
    }
    else if (attachment.attachmentType == QMAttachmentContentTypeVideo) {
        QMMessageAttachmentStatus status = [self attachmentStatusForMessage:message];
        BOOL isReady = status == QMMessageAttachmentStatusLoaded || status == QMMessageAttachmentStatusNotLoaded;
        return attachment.ID != nil && isReady;
    }
    else if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        return attachment.image != nil;
    }
    return NO;
}

- (QBChatAttachment *)cachedAttachmentWithID:(NSString *)attachmentID
                                forMessageID:(NSString *)messageID {
    
    return [self.storeService cachedAttachmentWithID:attachmentID
                                        forMessageID:messageID];
}


- (void)removeAllMediaFiles {
    
    [self.storeService clearCacheForType:QMAttachmentCacheTypeMemory|QMAttachmentCacheTypeDisc
                              completion:nil];
    [self.attachmentsStates removeAllObjects];
}

- (void)removeMediaFilesForDialogWithID:(NSString *)dialogID {
    
    [self.storeService clearCacheForDialogWithID:dialogID
                                       cacheType:QMAttachmentCacheTypeMemory|QMAttachmentCacheTypeDisc
                                      completion:nil];
}

- (void)removeMediaFilesForMessagesWithID:(NSArray<NSString *> *)messagesIDs
                                 dialogID:(NSString *)dialogID {
    for (NSString *messageID in messagesIDs) {
        self.attachmentsStates[messageID] = nil;
    }
    [self.storeService clearCacheForMessagesWithIDs:messagesIDs
                                           dialogID:dialogID
                                          cacheType:QMAttachmentCacheTypeMemory|QMAttachmentCacheTypeDisc
                                         completion:nil];
}

- (void)removeMediaFilesForMessageWithID:(NSString *)messageID
                                dialogID:(NSString *)dialogID {
    
    self.attachmentsStates[messageID] = nil;
    
    [self.storeService clearCacheForMessagesWithIDs:@[messageID]
                                           dialogID:dialogID
                                          cacheType:QMAttachmentCacheTypeMemory|QMAttachmentCacheTypeDisc
                                         completion:nil];
}


//MARK:- Add / Remove Multicast delegate

- (void)setDelegate:(id<QMChatAttachmentServiceDelegate>)delegate {
    
    if (delegate) {
        [self.multicastDelegate addDelegate:delegate];
    }
}

- (void)addDelegate:(id <QMChatAttachmentServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMChatAttachmentServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}


- (void)changeMessageAttachmentStatus:(QMMessageAttachmentStatus)status
                           forMessage:(QBChatMessage *)message {
    
    if ([self.attachmentsStates[message.ID] isEqualToNumber:@(status)]) {
        return;
    }
    
    self.attachmentsStates[message.ID] = @(status);
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatAttachmentService:
                                                             didChangeAttachmentStatus:
                                                             forMessage:)]) {
        [self.multicastDelegate chatAttachmentService:self
                            didChangeAttachmentStatus:status
                                           forMessage:message];
    }
}

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                     withAttachedImage:(UIImage *)image
                            completion:(QBChatCompletionBlock)completion {
    
    QBChatAttachment *attachment = [QBChatAttachment imageAttachmentWithImage:image];
    [self uploadAndSendAttachmentMessage:message
                                toDialog:dialog
                         withChatService:chatService
                              attachment:attachment
                              completion:completion];
    
}

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                            attachment:(QBChatAttachment *)attachment
                            completion:(QBChatCompletionBlock)completion {
    
    [chatService.deferredQueueManager addOrUpdateMessage:message];
    
    [self uploadAttachmentMessage:message
                         toDialog:dialog
                       attachment:attachment
                       completion:^(NSError *error, BOOL cancelled) {
                           if (cancelled) {
                               [chatService deleteMessageLocally:message];
                               if (completion) {
                                   completion(nil);
                               }
                               return;
                           }
                           if (!error) {
                               [chatService sendMessage:message
                                               toDialog:dialog
                                          saveToHistory:YES
                                          saveToStorage:YES
                                             completion:completion];
                           }
                           else {
                               [chatService.deferredQueueManager addOrUpdateMessage:message];
                               if (completion) {
                                   completion(error);
                               }
                           }
                       }];
}

- (void)uploadAttachmentMessage:(QBChatMessage *)message
                       toDialog:(QBChatDialog *)dialog
                     attachment:(QBChatAttachment *)attachment
                     completion:(void(^)(NSError *error, BOOL cancelled))completion {
    
    BOOL hasOperation = NO;
    @synchronized (self.runningOperations) {
        hasOperation = self.runningOperations[message.ID] != nil;
    }
    
    if (hasOperation) {
        return;
    }
    
    message.attachments = @[attachment];
    
    void(^progressBlock)(float progress) = ^(float progress) {
        
        if ([self.multicastDelegate respondsToSelector:@selector(chatAttachmentService:
                                                                 didChangeUploadingProgress:
                                                                 forMessage:)]) {
            [self.multicastDelegate chatAttachmentService:self
                               didChangeUploadingProgress:progress
                                               forMessage:message];
        }
    };
    
    
    QMAttachmentOperation *attachmentOperation = [QMAttachmentOperation new];
    attachmentOperation.identifier = message.ID;
    
    @synchronized (self.runningOperations) {
        self.runningOperations[message.ID] = attachmentOperation;
    }
    
    __weak QMAttachmentOperation *weakOperation = attachmentOperation;
    
    // Create the dispatch group
    dispatch_group_t uploadGroup = dispatch_group_create();
    
    if (!attachment.isPrepared) {
        
        dispatch_group_enter(uploadGroup);
        
        [self.assetService loadAssetForAttachment:attachment
                                        messageID:message.ID
                                       completion:^(UIImage * _Nullable image,
                                                    Float64 durationInSeconds,
                                                    CGSize size,
                                                    NSError * _Nullable error,
                                                    BOOL cancelled) {
                                           if (!cancelled) {
                                               if (!error) {
                                                   attachment.image = image;
                                                   attachment.duration = durationInSeconds;
                                                   attachment.width = size.width;
                                                   attachment.height = size.height;
                                               }
                                               
                                           }
                                           dispatch_group_leave(uploadGroup);
                                       }];
    }
    
    dispatch_group_wait(uploadGroup,DISPATCH_TIME_FOREVER);
    
    [self.storeService cachedDataForAttachment:attachment
                                     messageID:message.ID
                                      dialogID:message.dialogID
                                    completion:^(NSURL * _Nonnull fileURL, NSData * _Nonnull data)
     {
         QMSLog(@"_UPLOAD 1 STORE SERVICE completion %@",message.ID);
         __strong __typeof(weakOperation) strongOperation = weakOperation;
         if (attachmentOperation.isCancelled) {
             QMSLog(@"_UPLOAD 2 is Cancelled %@",message.ID);
             
             [self safelyRemoveOperationFromRunning:strongOperation];
             return;
         }
         if (fileURL) {
             QMSLog(@"_UPLOAD 3 has file URL %@",message.ID);
             [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded
                                      forMessage:message];
             attachment.localFileURL = fileURL;
             completion(nil,attachmentOperation.isCancelled);
             [self safelyRemoveOperationFromRunning:strongOperation];
         }
         else {
             if ([self attachmentStatusForMessage:message] == QMMessageAttachmentStatusUploading) {
                 QMSLog(@"_UPLOAD 4 STATUS IS LOADING ID ID: %@", message.ID);
                 return;
             }
             
             [self changeMessageAttachmentStatus:QMMessageAttachmentStatusUploading
                                      forMessage:message];
             
             
             void(^operationCompletionBlock)(QMUploadOperation *operation) = ^(QMUploadOperation *operation)
             {
                 NSError * error = operation.error;
                 __strong __typeof(weakOperation) strongOperation = weakOperation;
                 
                 if (!strongOperation || strongOperation.isCancelled) {
                     [self safelyRemoveOperationFromRunning:strongOperation];
                     [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded
                                              forMessage:message];
                     return;
                 }
                 else if (error) {
                     [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded
                                              forMessage:message];
                     [self safelyRemoveOperationFromRunning:strongOperation];
                     completion(error,attachmentOperation.isCancelled);
                 }
                 else {
                     
                     [self.storeService storeAttachment:attachment
                                               withData:nil
                                              cacheType:QMAttachmentCacheTypeDisc|QMAttachmentCacheTypeMemory
                                              messageID:message.ID
                                               dialogID:message.dialogID
                                             completion:^{
                                                 
                                                 if (strongOperation && !strongOperation.isCancelled) {
                                                     [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded
                                                                              forMessage:message];
                                                     
                                                     completion(nil,attachmentOperation.isCancelled);
                                                     [self safelyRemoveOperationFromRunning:strongOperation];
                                                 }
                                                 else {
                                                     [self safelyRemoveOperationFromRunning:strongOperation];
                                                 }
                                             }];
                 }
             };
             
             if (attachment.attachmentType == QMAttachmentContentTypeImage) {
                 NSData *imageData = [self.storeService dataForImage:attachment.image];
                 [self.contentService uploadAttachment:attachment messageID:message.ID withData:imageData progressBlock:progressBlock completionBlock:operationCompletionBlock];
             }
             else {
                 [self.contentService
                  uploadAttachment:attachment messageID:message.ID withFileURL:attachment.localFileURL progressBlock:progressBlock completionBlock:operationCompletionBlock];
             }
         }
     }];
    
    
    attachmentOperation.cancelBlock = ^{
        
        __strong __typeof(weakOperation) strongOperation = weakOperation;
        
        [self.contentService cancelOperationWithID:strongOperation.identifier];
        [self safelyRemoveOperationFromRunning:strongOperation];
        
        completion(nil, YES);
    };
}

- (void)attachmentWithID:(NSString *)attachmentID
                 message:(QBChatMessage *)message
           progressBlock:(QMAttachmentProgressBlock)progressBlock
              completion:(void(^)(QMAttachmentOperation *))completionBlock {
    
    if (!attachmentID) {
        return;
    }
    
    QMAttachmentOperation *attachmentOperation = [QMAttachmentOperation new];
    attachmentOperation.identifier = message.ID;
    
    @synchronized (self.runningOperations) {
        self.runningOperations[message.ID] = attachmentOperation;
    }
    
    QBChatAttachment *attachment = message.attachments.firstObject;
    
    NSParameterAssert(attachment != nil);
    __weak QMAttachmentOperation *weakOperation = attachmentOperation;
    
    if (attachment.attachmentType == QMAttachmentContentTypeAudio
        || attachment.attachmentType == QMAttachmentContentTypeImage
        || attachment.attachmentType == QMAttachmentContentTypeCustom) {
        
        if ([self attachmentStatusForMessage:message] == QMMessageAttachmentStatusLoading) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self.storeService cachedDataForAttachment:attachment
                                         messageID:message.ID
                                          dialogID:message.dialogID
                                        completion:^(NSURL *fileURL, NSData *data)
         {
             
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             if (attachmentOperation.isCancelled) {
                 
                 __strong __typeof(weakOperation) strongOperation = weakOperation;
                 [strongSelf safelyRemoveOperationFromRunning:strongOperation];
                 return;
             }
             
             if (fileURL) {
                 
                 [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded
                                          forMessage:message];
                 if (attachment.attachmentType == QMAttachmentContentTypeImage) {
                     attachment.image = [UIImage imageWithData:data];
                 }
                 attachment.localFileURL = fileURL;
                 attachmentOperation.attachment = attachment;
                 completionBlock(attachmentOperation);
                 return;
             }
             
             [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading
                                            forMessage:message];
             
             [strongSelf.contentService downloadAttachmentWithID:attachmentID
                                                         message:message
                                                   progressBlock:^(float progress) {
                                                       [strongSelf updateLoadingProgress:progress
                                                                           forAttachment:attachment
                                                                                 message:message];
                                                       if (progressBlock) {
                                                           progressBlock(progress);
                                                       }
                                                   }
                                                 completionBlock:^(QMDownloadOperation * _Nonnull downloadOperation) {
                                                     
                                                     if (!downloadOperation || downloadOperation.isCancelled) {
                                                         [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded
                                                                                        forMessage:message];
                                                         return;
                                                     }
                                                     if (downloadOperation.error) {
                                                         [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusError
                                                                                        forMessage:message];
                                                         
                                                         attachmentOperation.error = downloadOperation.error;
                                                         
                                                         completionBlock(attachmentOperation);
                                                     }
                                                     else if (downloadOperation.data) {
                                                         attachment.ID = attachmentID;
                                                         
                                                         [strongSelf.storeService storeAttachment:attachment
                                                                                         withData:downloadOperation.data
                                                                                        cacheType:QMAttachmentCacheTypeDisc|QMAttachmentCacheTypeMemory
                                                                                        messageID:message.ID
                                                                                         dialogID:message.dialogID
                                                                                       completion:^
                                                          {
                                                              
                                                              [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded
                                                                                             forMessage:message];
                                                              
                                                              if (downloadOperation && !downloadOperation.isCancelled) {
                                                                  if (!attachment.isPrepared) {
                                                                      [strongSelf prepareAttachment:attachment
                                                                                            message:message
                                                                                         completion:^(UIImage * _Nullable image, Float64 durationSeconds, CGSize size, NSError * _Nullable error, BOOL cancelled)
                                                                       {
                                                                           if (!cancelled) {
                                                                               if (error) {
                                                                                   attachmentOperation.error = error;
                                                                               }
                                                                               else {
                                                                                   attachment.image = image;
                                                                                   attachment.duration = durationSeconds;
                                                                                   
                                                                                   [self.storeService updateAttachment:attachment messageID:message.ID dialogID:message.dialogID];
                                                                                   attachmentOperation.attachment = attachment;
                                                                               }
                                                                               completionBlock(attachmentOperation);
                                                                           }
                                                                       }];
                                                                  }
                                                                  else {
                                                                      attachmentOperation.attachment = attachment;
                                                                      completionBlock(attachmentOperation);
                                                                  }
                                                              }
                                                          }];
                                                     }
                                                     
                                                 }];
         }];
        
        attachmentOperation.cancelBlock = ^{
            
            __strong __typeof(weakOperation) strongOperation = weakOperation;
            
            [self.assetService cancelOperationWithID:strongOperation.identifier];
            [self.contentService cancelOperationWithID:strongOperation.identifier];
            [self safelyRemoveOperationFromRunning:strongOperation];
        };
    }
    
}

- (void)safelyRemoveOperationFromRunning:(nullable QMAttachmentOperation *)operation {
    
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObjectForKey:operation.identifier];
        }
    }
}


- (QMMessageAttachmentStatus)attachmentStatusForMessage:(QBChatMessage *)message {
    
    QMMessageAttachmentStatus status = QMMessageAttachmentStatusNotLoaded;
    
    if (self.attachmentsStates[message.ID] != nil) {
        status = [self.attachmentsStates[message.ID] integerValue];
    }
    else {
        QBChatAttachment *attachment = [message.attachments firstObject];
        NSURL *fileURL = [self.storeService fileURLForAttachment:attachment
                                                       messageID:message.ID
                                                        dialogID:message.dialogID];
        if (fileURL != nil) {
            status = QMMessageAttachmentStatusLoaded;
        }
        else {
            BOOL downloading = [self.contentService isDownloadingMessageWithID:message.ID];
            if (downloading) {
                status = QMMessageAttachmentStatusLoading;
            }
        }
        self.attachmentsStates[message.ID] = @(status);
    }
    
    return status;
}


- (void)updateLoadingProgress:(CGFloat)progress
                forAttachment:(QBChatAttachment *)attachment
                      message:(QBChatMessage *)message {
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatAttachmentService:
                                                             didChangeLoadingProgress:
                                                             forChatAttachment:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.multicastDelegate chatAttachmentService:self
                             didChangeLoadingProgress:progress
                                    forChatAttachment:attachment];
#pragma clang diagnostic pop
    }
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatAttachmentService:
                                                             didChangeLoadingProgress:
                                                             forMessage:
                                                             attachment:)]) {
        [self.multicastDelegate chatAttachmentService:self
                             didChangeLoadingProgress:progress
                                           forMessage:message
                                           attachment:attachment];
    }
}

@end
