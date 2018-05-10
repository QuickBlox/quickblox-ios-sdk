//
//  QMMediaUploadService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/9/17.
//  Copyright © 2017 quickblox. All rights reserved.
//
#import <Quickblox/Quickblox.h>
#import "QMMediaUploadService.h"
#import "QMSLog.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QMBaseService.h"

@implementation  QMUploadOperation

@end


@interface QMMediaUploadService()

@property (strong, nonatomic) NSOperationQueue *uploadOperationQueue;
@property (strong, nonatomic) BFCancellationToken *cancellationToken;

@end

@implementation QMMediaUploadService



- (instancetype)init {
    
    if (self  = [super init]) {
        
        _uploadOperationQueue = [NSOperationQueue new];
        _uploadOperationQueue.name = @"QM.QMUploadOperationQueue";
        _uploadOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _uploadOperationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

//MARK: -NSObject
- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}


- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
             withFileURL:(NSURL *)fileURL
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *uploadOperation))completion {
    
    NSParameterAssert([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]);
    
    if ([_uploadOperationQueue hasOperationWithID:messageID]) {
        return;
    }
    
    QMUploadOperation *uploadOperation =  [QMUploadOperation new];
    uploadOperation.operationID = messageID;
    __weak __typeof(uploadOperation)weakOperation = uploadOperation;
    
    uploadOperation.cancelBlock = ^{
        __strong typeof(weakOperation) strongOperation = weakOperation;
        if (!strongOperation.objectToCancel) {
            completion(strongOperation);
        }
        else {
            [strongOperation.objectToCancel cancel];
        }
    };
    
    [uploadOperation setAsyncOperationBlock:^(dispatch_block_t  _Nonnull finish)
     {
         
         QBRequest *request = [QBRequest uploadFileWithUrl:fileURL
                                                  fileName:attachment.name
                                               contentType:attachment.contentType
                                                  isPublic:YES
                                              successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull tBlob)
                               {
                                   
                                   attachment.ID = tBlob.UID;
                                   attachment.size = tBlob.size;
                                   
                                   __strong typeof(weakOperation) strongOperation = weakOperation;
                                   strongOperation.attachmentID = attachment.ID;
                                   if (completion) {
                                       completion(strongOperation);
                                   }
                                   finish();
                               } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status)
                               {
                                   
                                   progressBlock(status.percentOfCompletion);
                                   QMSLog(@"Upload status = %f __  isCancelled %d", status.percentOfCompletion, request.isCancelled);
                                   
                               } errorBlock:^(QBResponse * _Nonnull response)
                               {
                                   __strong typeof(weakOperation) strongOperation = weakOperation;
                                   strongOperation.error = response.error.error;
                                   if (completion) {
                                       completion(strongOperation);
                                   }
                                   finish();
                               }];
         
         __strong typeof(weakOperation) strongOperation = weakOperation;
         strongOperation.objectToCancel = (id <QMCancellableObject>)request;
     }];
    
    
    [_uploadOperationQueue addOperation:uploadOperation];
}

- (BOOL)isUploadingMessageWithID:(NSString *)messageID {
    return [_uploadOperationQueue hasOperationWithID:messageID];
}

- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
                withData:(NSData *)data
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *uploadOperation))completion {
    
    NSParameterAssert(data != nil);
    
    for (QMUploadOperation *o in _uploadOperationQueue.operations) {
        
        if ([o.operationID isEqualToString:messageID]) {
            return;
        }
    }
    
    QMUploadOperation *uploadOperation =  [QMUploadOperation new];
    uploadOperation.operationID = messageID;
    
    __weak __typeof(uploadOperation)weakOperation = uploadOperation;
    
    uploadOperation.cancelBlock = ^{
        __strong typeof(weakOperation) strongOperation = weakOperation;
        
        if (!strongOperation.objectToCancel) {
            completion(strongOperation);
        }
        else {
            [strongOperation.objectToCancel cancel];
        }
    };
    
    
    [uploadOperation setAsyncOperationBlock:^(dispatch_block_t  _Nonnull finish)
     {
         weakOperation.objectToCancel = (id <QMCancellableObject>)
         [QBRequest TUploadFile:data
                       fileName:attachment.name
                    contentType:attachment.contentType
                       isPublic:NO
                   successBlock:^(QBResponse * _Nonnull response,
                                  QBCBlob * _Nonnull tBlob)
          {
              
              attachment.ID = tBlob.UID;
              attachment.size = tBlob.size;
              
              __strong typeof(weakOperation) strongOperation = weakOperation;
              strongOperation.attachmentID = tBlob.UID;
              if (completion) {
                  completion(strongOperation);
              }
              finish();
              
          } statusBlock:^(QBRequest * _Nonnull request,
                          QBRequestStatus * _Nullable status)
          {
              
              progressBlock(status.percentOfCompletion);
              
          } errorBlock:^(QBResponse * _Nonnull response)
          {
              __strong typeof(weakOperation) strongOperation = weakOperation;
              strongOperation.error = response.error.error;
              if (completion) {
                  completion(strongOperation);
              }
              finish();
          }];
         
     }];
    
    
    [_uploadOperationQueue addOperation:uploadOperation];
}

- (void)cancelAllOperations {
    [_uploadOperationQueue cancelAllOperations];
}

- (void)cancelOperationWithID:(NSString *)operationID {
    [_uploadOperationQueue cancelOperationWithID:operationID];
}



//MARK: BFTask Public methods

+ (BFTask <QBChatAttachment*> *)taskUploadAttachment:(QBChatAttachment *)attachment
                                            withData:(NSData *)data
                                       progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
                                   cancellationToken:(BFCancellationToken *)cancellationToken {
    
    __block QBCBlob *blob = nil;
    
    return  [[[[[taskCreateBlob(attachment, data.length, cancellationToken)
                 continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull t) {
                     blob = t.result;
                     return t;
                 }]
                continueWithSuccessBlock:uploadWithDataBlock(data, progressBlock, cancellationToken)]
               continueWithSuccessBlock:continuationCompleteBlobBlock(cancellationToken)]
              continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                  attachment.size = data.length;
                  attachment.ID = t.result;
                  return [BFTask taskWithResult:attachment];
                  
              }] continueWithBlock:continuationCompletionBlock(blob)];
    
}


+ (BFTask <QBChatAttachment*> *)taskUploadAttachment:(QBChatAttachment *)attachment
                                         withFileURL:(NSURL *)fileURL
                                       progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
                                   cancellationToken:(BFCancellationToken *)cancellationToken {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
    NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
    NSUInteger fileSize = fileSizeNumber.unsignedIntegerValue;
    
    __block QBCBlob *blob = nil;
    
    return  [[[[[taskCreateBlob(attachment, fileSize, cancellationToken)
                 
                 continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull t) {
                     blob = t.result;
                     return t;
                 }]
                
                continueWithSuccessBlock:uploadWithURLBlock(fileURL, progressBlock, cancellationToken)]
               continueWithSuccessBlock:continuationCompleteBlobBlock(cancellationToken)]
              continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                  attachment.size = fileSize;
                  attachment.ID = t.result;
                  return [BFTask taskWithResult:attachment];
              }]
             continueWithBlock:continuationCompletionBlock(blob)];
}

//MARK: BFTask Private static functions

static inline BFTask<QBCBlob*> * taskCreateBlob(QBChatAttachment *attachment, NSUInteger size, BFCancellationToken *cancellationToken) {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        QBCBlob *blob = [QBCBlob blob];
        blob.name = attachment.name;
        blob.contentType = attachment.contentType;
        blob.isPublic = YES;
        blob.size = size;
        
        QBRequest *request = [QBRequest createBlob:blob
                                      successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull tBlob)
                              {
                                  tBlob.size = size;
                                  [source setResult:tBlob];
                              } errorBlock:^(QBResponse * _Nonnull response) {
                                  [source setError:response.error.error];
                              }];
        
        [cancellationToken registerCancellationObserverWithBlock:^{
            [request cancel];
        }];
        
    });
}

static inline BFTask<NSString*> * taskCompleteBlob(QBCBlob *blob, BFCancellationToken *cancellationToken) {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        QBRequest *request = [QBRequest completeBlobWithID:blob.ID
                                                      size:blob.size
                                              successBlock:^(QBResponse * _Nonnull response)
                              {
                                  [source setResult:blob.UID];
                              } errorBlock:^(QBResponse * _Nonnull response) {
                                  [source setError:response.error.error];
                              }];
        [cancellationToken registerCancellationObserverWithBlock:^{
            [request cancel];
        }];
    });
}

static BFContinuationBlock continuationCompleteBlobBlock(BFCancellationToken * cancellationToken) {
    
    BFContinuationBlock  continuationCompleteBlobBlock = ^id(BFTask <QBCBlob *>*task) {
        return taskCompleteBlob(task.result, cancellationToken);
    };
    return continuationCompleteBlobBlock;
}



static BFContinuationBlock continuationCompletionBlock(QBCBlob *blob) {
    
    BFContinuationBlock continuationCompletionBlock = ^id(BFTask *task) {
        
        //Blob should be deleted if any of the previous 'BFTask's was canceled or completed with error.
        if (task.error || task.cancelled) {
            if (blob.ID > 0) {
                return [taskDeleteBlob(blob) continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                    return task;
                }];
            }
        }
        
        return task;
    };
    
    return continuationCompletionBlock;
}

static BFContinuationBlock uploadWithDataBlock(NSData *data,
                                               _Nullable QMAttachmentProgressBlock progressBlock,
                                               BFCancellationToken * cancellationToken) {
    
    BFContinuationBlock continuationUploadBlobBlock = ^id(BFTask <QBCBlob *>*task) {
        
        return taskUploadFileWithData(data,
                                      task.result,
                                      progressBlock,
                                      cancellationToken);
    };
    
    return continuationUploadBlobBlock;
}

static BFContinuationBlock uploadWithURLBlock(NSURL *url,
                                              _Nullable QMAttachmentProgressBlock progressBlock,
                                              BFCancellationToken * cancellationToken) {
    
    BFContinuationBlock continuationUploadBlobBlock = ^id(BFTask <QBCBlob *>*task) {
        
        return taskUploadFileWithURL(url,
                                     task.result,
                                     progressBlock,
                                     cancellationToken);
    };
    
    return continuationUploadBlobBlock;
}

static BFTask <QBCBlob *>*taskUploadFileWithURL(NSURL *fileURL,
                                                QBCBlob *blob,
                                                _Nullable QMAttachmentProgressBlock progressBlock,
                                                BFCancellationToken *cancellationToken) {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        QBRequest *request = [QBRequest uploadWithUrl:fileURL
                                  blobWithWriteAccess:blob
                                         successBlock:^(QBResponse * _Nonnull response) {
                                             [source setResult:blob];
                                         } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
                                             progressBlock ? progressBlock(status.percentOfCompletion) : nil;
                                         } errorBlock:^(QBResponse * _Nonnull response) {
                                             [source setError:response.error.error];
                                         }];
        
        [cancellationToken registerCancellationObserverWithBlock:^{
            [request cancel];
        }];
    });
}

static BFTask <QBCBlob *>*taskUploadFileWithData(NSData *data,
                                                 QBCBlob *blob,
                                                 _Nullable QMAttachmentProgressBlock progressBlock,
                                                 BFCancellationToken *cancellationToken) {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        QBRequest *request = [QBRequest uploadFile:data
                               blobWithWriteAccess:blob
                                      successBlock:^(QBResponse * _Nonnull response) {
                                          [source setResult:blob];
                                      } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
                                          progressBlock ? progressBlock(status.percentOfCompletion) : nil;
                                      } errorBlock:^(QBResponse * _Nonnull response) {
                                          [source setError:response.error.error];
                                      }];
        [cancellationToken registerCancellationObserverWithBlock:^{
            [request cancel];
        }];
        
    });
}

static BFTask <QBCBlob *>*taskDeleteBlob(QBCBlob *blob) {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [QBRequest deleteBlobWithID:blob.ID
                       successBlock:^(QBResponse * _Nonnull response) {
                           [source setResult:blob];
                       }
                         errorBlock:^(QBResponse * _Nonnull response) {
                             [source setResult:response.error.error];
                         }];
    });
}

@end
