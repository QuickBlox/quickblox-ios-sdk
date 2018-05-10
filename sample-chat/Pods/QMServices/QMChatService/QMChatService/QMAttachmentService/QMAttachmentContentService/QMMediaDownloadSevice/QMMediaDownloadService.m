//
//  QMMediaDownloadService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMMediaDownloadServiceDelegate.h"
#import "QMMediaDownloadService.h"

#import "QMMediaBlocks.h"
#import "QMSLog.h"

@implementation QMDownloadOperation
    
@end

@interface QMMediaDownloadService()
    
@property (strong, nonatomic) NSOperationQueue *downloadOperationQueue;
    
@end

@implementation QMMediaDownloadService
    
- (instancetype)init {
    
    if (self  = [super init]) {
        
        _downloadOperationQueue = [NSOperationQueue new];
        _downloadOperationQueue.name = @"QM.QMDownloadOperationQueue";
        _downloadOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _downloadOperationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}
    
- (void)dealloc {
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}
    
- (void)downloadAttachmentWithID:(NSString *)attachmentID
                       messageID:(NSString *)messageID
                   progressBlock:(QMAttachmentProgressBlock)progressBlock
                 completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion {
    
    NSParameterAssert(attachmentID.length);
    NSParameterAssert(messageID.length);
    
    if  ([_downloadOperationQueue hasOperationWithID:messageID]) {
        return;
    }
    
    QMDownloadOperation *downloadOperation =  [QMDownloadOperation new];
    downloadOperation.operationID = messageID;
    
    __weak __typeof(downloadOperation)weakOperation = downloadOperation;
    
    downloadOperation.cancelBlock = ^{
        __strong typeof(weakOperation) strongOperation = weakOperation;
        QMSLog(@"Cancell operation with ID: %@", strongOperation.operationID);
        if (!strongOperation.objectToCancel) {
            completion(strongOperation);
        }
        [strongOperation.objectToCancel cancel];
        strongOperation.objectToCancel = nil;
    };
    
    [downloadOperation setAsyncOperationBlock:^(dispatch_block_t _Nonnull finish) {
        QMSLog(@"Start Download operation with ID: %@", weakOperation.operationID);
        
        NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        //Backward compatibility for attachments with integer ID
        if ([attachmentID rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
            
            weakOperation.objectToCancel = (id <QMCancellableObject>)[QBRequest downloadFileWithID:attachmentID.integerValue
                                                                                      successBlock:^(QBResponse * _Nonnull response,
                                                                                                     NSData * _Nonnull fileData)
                                                                      {
                                                                          QMSLog(@"Complete operation with ID: %@", weakOperation.operationID);
                                                                          
                                                                          __strong typeof(weakOperation) strongOperation = weakOperation;
                                                                          strongOperation.data = fileData;
                                                                          completion(strongOperation);
                                                                          finish();
                                                                      } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status)
                                                                      {
                                                                          if (progressBlock) {
                                                                              QMSLog(@"donwload progress %f",status.percentOfCompletion);
                                                                              progressBlock(status.percentOfCompletion);
                                                                          }
                                                                      } errorBlock:^(QBResponse * _Nonnull response)
                                                                      {
                                                                          QMSLog(@"Error operation with ID: %@", weakOperation.operationID);
                                                                          __strong typeof(weakOperation) strongOperation = weakOperation;
                                                                          strongOperation.error = response.error.error;
                                                                          completion(strongOperation);
                                                                          finish();
                                                                      }];
        }
        else {
            
            weakOperation.objectToCancel = (id <QMCancellableObject>)[QBRequest backgroundDownloadFileWithUID:attachmentID
                                                                                                 successBlock:^(QBResponse * _Nonnull response,
                                                                                                                NSData * _Nonnull fileData)
                                                                      {
                                                                          QMSLog(@"Complete operation with ID: %@", weakOperation.operationID);
                                                                          
                                                                          __strong typeof(weakOperation) strongOperation = weakOperation;
                                                                          strongOperation.data = fileData;
                                                                          completion(strongOperation);
                                                                          finish();
                                                                          
                                                                      } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status)
                                                                      {
                                                                          if (progressBlock) {
                                                                              QMSLog(@"donwload progress %f",status.percentOfCompletion);
                                                                              progressBlock(status.percentOfCompletion);
                                                                          }
                                                                      } errorBlock:^(QBResponse * _Nonnull response)
                                                                      {
                                                                          QMSLog(@"Error operation with ID: %@", weakOperation.operationID);
                                                                          __strong typeof(weakOperation) strongOperation = weakOperation;
                                                                          strongOperation.error = response.error.error;
                                                                          completion(strongOperation);
                                                                          finish();
                                                                      }];
        }
    }];
    
    [_downloadOperationQueue addOperation:downloadOperation];
}
    
- (BOOL)isDownloadingMessageWithID:(NSString *)messageID {
    return [self.downloadOperationQueue hasOperationWithID:messageID];
}
    
//MARK: - QMCancellableService
    
- (void)cancelOperationWithID:(NSString *)operationID {
    
    [self.downloadOperationQueue cancelOperationWithID:operationID];
}
    
- (void)cancelAllOperations {
    
    [self.downloadOperationQueue cancelAllOperations];
}
    
@end
