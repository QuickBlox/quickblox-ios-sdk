//
//  AttachmentDownloadOperation.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadOperation.h"

@implementation AttachmentDownloadOperation

//MARK: - Life Cycle
- (instancetype)initWithAttachmentID:(NSString *)attachmentID
                     progressHandler:(ProgressHandler)progressHandler
                      successHandler:(SuccessHandler)successHandler
                        errorHandler:(ErrorHandler)errorHandler {
    self = [super init];
    if (self) {
        self.attachmentID = attachmentID;
        self.progressHandler = progressHandler;
        self.successHandler = successHandler;
        self.errorHandler = errorHandler;
    }
    return self;
}

- (void)main {
    if (self.isCancelled) {
        self.state = AsyncOperationStateStateFinished;
        return;
    }
    
    [self downloadAttachmentWithID:self.attachmentID];
}

//MARK: - Internal Methods
- (void)downloadAttachmentWithID:(NSString *)ID {
    self.state = AsyncOperationStateStateExecuting;
    
    __weak typeof(self)weakSelf = self;
    
    [QBRequest downloadFileWithUID:ID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
        if (![UIImage imageWithData:fileData]) {
            weakSelf.state = AsyncOperationStateStateFinished;
            return ;
        }
        
        UIImage *image = [UIImage imageWithData:fileData];
        weakSelf.successHandler(image, ID);
        weakSelf.state = AsyncOperationStateStateFinished;
        
    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
        CGFloat progress = status.percentOfCompletion;
        weakSelf.progressHandler(progress, ID);
    } errorBlock:^(QBResponse * _Nonnull response) {
        weakSelf.errorHandler(response.error.error, ID);
        weakSelf.state = AsyncOperationStateStateFinished;
    }];
}

@end
