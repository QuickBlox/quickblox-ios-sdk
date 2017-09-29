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

@implementation  QMUploadOperation

@end

@interface QMMediaUploadService()

@property (strong, nonatomic) NSOperationQueue *uploadOperationQueue;

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
              strongOperation.operationID = tBlob.UID;
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

@end
