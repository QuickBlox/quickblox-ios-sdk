//
//  AttachmentDownloadOperation.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadOperation.h"
#import <Quickblox/Quickblox.h>

@implementation AttachmentDownloadOperation

//MARK: - Life Cycle
- (instancetype)initWithAttachmentID:(NSString *)attachmentID
                      attachmentName:(NSString *)attachmentName
                      attachmentType:(AttachmentType)attachmentType
                     progressHandler:(ProgressHandler)progressHandler
                      successHandler:(SuccessHandler)successHandler
                        errorHandler:(ErrorHandler)errorHandler {
    self = [super init];
    if (self) {
        self.attachmentID = attachmentID;
        self.attachmentName = attachmentName;
        self.attachmentType = attachmentType;
        self.progressHandler = progressHandler;
        self.successHandler = successHandler;
        self.errorHandler = errorHandler;
    }
    return self;
}

- (void)main {
    if (self.isCancelled) {
        self.state = AsyncOperationStateFinished;
        return;
    }
    
    [self downloadAttachmentWithID:self.attachmentID attachmentName:self.attachmentName attachmentType:self.attachmentType];
}

//MARK: - Internal Methods
- (void)downloadAttachmentWithID:(NSString *)ID attachmentName:(NSString *)attachmentName attachmentType:(AttachmentType)attachmentType {
    self.state = AsyncOperationStateExecuting;
    
    __weak typeof(self)weakSelf = self;
    
    [QBRequest downloadFileWithUID:ID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
        
        if (attachmentType == AttachmentTypeImage && [UIImage imageWithData:fileData]) {
            UIImage *image = [UIImage imageWithData:fileData];
            weakSelf.successHandler(image, nil, ID);
        } else {
            NSString *fileName = [NSString stringWithFormat:@"%@_%@", ID, attachmentName];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            if ([fileData writeToURL:fileURL atomically:YES]) {
                weakSelf.successHandler(nil, fileURL, ID);
            }
            else {
                NSLog(@"failure");
            }
        }
        weakSelf.state = AsyncOperationStateFinished;
        
    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
        CGFloat progress = status.percentOfCompletion;
        weakSelf.progressHandler(progress, ID);
    } errorBlock:^(QBResponse * _Nonnull response) {
        weakSelf.errorHandler(response.error.error, ID);
        weakSelf.state = AsyncOperationStateFinished;
    }];
}

@end
