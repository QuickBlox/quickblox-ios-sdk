//
//  QMMediaInfoService.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 2/22/17.
//
//

#import "QMAttachmentAssetService.h"
#import "QMAsynchronousOperation.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QMAssetLoader.h"
#import "QMSLog.h"

@interface QMAttachmentAssetService()

@property (strong, nonatomic) NSOperationQueue *assetServiceOperationQueue;
@property (weak, nonatomic, nullable) NSOperation *lastAddedOperation;
@property (strong, nonatomic) NSMutableDictionary *mediaInfoStorage;
@end

@implementation QMAttachmentAssetService

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _assetServiceOperationQueue = [[NSOperationQueue alloc] init];
        _assetServiceOperationQueue.maxConcurrentOperationCount  = 2;
        _assetServiceOperationQueue.qualityOfService = NSQualityOfServiceUtility;
        _assetServiceOperationQueue.name = @"QMServices.assetServiceOperationQueue";
        _mediaInfoStorage = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)loadAssetForAttachment:(QBChatAttachment *)attachment
                     messageID:(NSString *)messageID
                    completion:(QMAttachmentAssetLoaderCompletionBlock)completion
{
    NSParameterAssert(attachment.localFileURL?:attachment.remoteURL);
    
    if ([_assetServiceOperationQueue hasOperationWithID:messageID]) {
        return;
    }
    
    QMAsynchronousOperation *assetLoaderOperation = [[QMAsynchronousOperation alloc] init];
    assetLoaderOperation.operationID = messageID;
    __weak __typeof(assetLoaderOperation)weakOperation = assetLoaderOperation;
    
    assetLoaderOperation.cancelBlock = ^{
        __strong typeof(weakOperation) strongOperation = weakOperation;
        QMSLog(@"Cancell operation with ID: %@", strongOperation.operationID);
        if (!strongOperation.objectToCancel) {
            completion(nil, 0, CGSizeZero, nil, YES);
        }
        
        [strongOperation.objectToCancel cancel];
        strongOperation.objectToCancel = nil;
    };
    
    [assetLoaderOperation setAsyncOperationBlock:^(dispatch_block_t  _Nonnull finish) {
        
        QMAssetLoader *assetLoader = [QMAssetLoader loaderForAttachment:attachment
                                                              messageID:messageID];
        
        weakOperation.objectToCancel = (id <QMCancellableObject>)assetLoader;
        
        [assetLoader loadWithTimeOut:60.0
                     completionBlock:^(NSTimeInterval duration,
                                       CGSize size,
                                       UIImage * _Nullable image,
                                       NSError * _Nullable error) {
            completion(image, duration, size, error, weakOperation.isCancelled);
            finish();
        }];
    }];
    
    [self.assetServiceOperationQueue addOperation:assetLoaderOperation];
    
//    //LIFO order
//    [self.lastAddedOperation addDependency:assetLoaderOperation];
//    self.lastAddedOperation = assetLoaderOperation;
}

//MARK: QMCancellableService

- (void)cancelAllOperations {
    
    [self.assetServiceOperationQueue cancelAllOperations];
}

- (void)cancelOperationWithID:(NSString *)operationID {
    
    for (QMAsynchronousOperation *op in self.assetServiceOperationQueue.operations) {
        if ([op.operationID isEqualToString:operationID]) {
            [op cancel];
            QMSLog(@"_Cancell operation with ID (info service):%@",operationID);
            break;
        }
    }
    
    //    [self.imagesOperationQueue cancelOperationWithID:operationID];
    QMSLog(@"Operations = %@", [self.assetServiceOperationQueue operations]);
}

@end

