//
//  QMMediaInfoService.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 2/22/17.
//
//

#import "QMAttachmentAssetService.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QMAssetLoader.h"
#import "QMSLog.h"

@interface QMAttachmentAssetService()

@property (strong, nonatomic) NSOperationQueue *assetServiceOperationQueue;
@property (weak, nonatomic, nullable) NSOperation *lastAddedOperation;

@end

@implementation QMAttachmentAssetService

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _assetServiceOperationQueue = [[NSOperationQueue alloc] init];
        _assetServiceOperationQueue.maxConcurrentOperationCount  = 2;
        _assetServiceOperationQueue.qualityOfService = NSQualityOfServiceUtility;
        _assetServiceOperationQueue.name = @"QMServices.assetServiceOperationQueue";
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
    
    NSURL *url = attachment.localFileURL ?: [attachment remoteURLWithToken:YES];
    
    QMAssetOperation *assetLoaderOperation =
    [[QMAssetOperation alloc] initWithID:messageID
                                     URL:url
                          attachmentType:attachment.attachmentType
                                 timeOut:60
                                 options:QMAssetLoaderKeyImage|QMAssetLoaderKeyTracks|QMAssetLoaderKeyPlayable
                         completionBlock:^(NSTimeInterval duration,
                                           CGSize size,
                                           UIImage * _Nullable image,
                                           NSError * _Nullable error)
     {
         if (completion) {
             completion(image, duration, size, error, NO);
         }
     }];
    
    assetLoaderOperation.cancelBlock = ^{
        if (completion) {
            completion(nil, 0, CGSizeZero, nil, YES);
        }
    };
    
    [_assetServiceOperationQueue addOperation:assetLoaderOperation];
    
    QMSLog(@"Operations = %@", self.assetServiceOperationQueue.operations);
    
    //LIFO order
    [self.lastAddedOperation addDependency:assetLoaderOperation];
    self.lastAddedOperation = assetLoaderOperation;
}


//MARK: QMCancellableService

- (void)cancelAllOperations {
    [self.assetServiceOperationQueue cancelAllOperations];
}

- (void)cancelOperationWithID:(NSString *)operationID {
    [self.assetServiceOperationQueue cancelOperationWithID:operationID];
}

@end

