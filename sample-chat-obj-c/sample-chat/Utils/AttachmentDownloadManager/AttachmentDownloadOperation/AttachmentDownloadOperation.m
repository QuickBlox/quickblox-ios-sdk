//
//  AttachmentDownloadOperation.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadOperation.h"
#import <Quickblox/Quickblox.h>
#import "ImageCache.h"
#import "Log.h"
#import "NSURL+Chat.h"
#import "UIImage+fixOrientation.h"

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
        __typeof(weakSelf)strongSelf = weakSelf;
        if (attachmentType == AttachmentTypeImage && [UIImage imageWithData:fileData]) {
            UIImage *image = [UIImage imageWithData:fileData];
            image = [image fixOrientation];
            [ImageCache.instance storeImage:image forKey:ID];
            if (!strongSelf) {
                return;
            }
            strongSelf.successHandler(image, nil, ID);
        } else {
            NSString *fileName = [NSString stringWithFormat:@"%@_%@", ID, attachmentName];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            if ([fileData writeToURL:fileURL atomically:YES]) {
                [ImageCache.instance getFileWithStringUrl:fileURL.absoluteString completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                    if (error) {
                        Log(@"Failure in the Cache of video error: %@", error.localizedDescription);
                        if (!strongSelf) {
                            return;
                        }
                        strongSelf.successHandler(nil, nil, ID);
                    } else if (url) {
                        [url getThumbnailImageFromVideoUrlWithCompletion:^(UIImage * _Nullable thumbnailImage) {
                            [ImageCache.instance storeImage:thumbnailImage forKey:ID];
                            if (!strongSelf) {
                                return;
                            }
                            strongSelf.successHandler(thumbnailImage, url, ID);
                        }];
                    }
                }];
                
            } else {
                NSLog(@"failure");
                if (!strongSelf) {
                    return;
                }
                strongSelf.successHandler(nil, nil, ID);
            }
        }
        strongSelf.state = AsyncOperationStateFinished;
        
    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
        CGFloat progress = status.percentOfCompletion;
        weakSelf.progressHandler(progress, ID);
    } errorBlock:^(QBResponse * _Nonnull response) {
        weakSelf.errorHandler(response.error.error, ID);
        weakSelf.state = AsyncOperationStateFinished;
    }];
}

@end
