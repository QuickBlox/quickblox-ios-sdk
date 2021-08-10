//
//  AttachmentDownloadManager.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadManager.h"
#import "AttachmentDownloadOperation.h"
#import "SDImageCache.h"
#import "UIImage+fixOrientation.h"
#import "NSURL+Chat.h"
#import "CacheManager.h"

@interface AttachmentDownloadManager()
@property (nonatomic, strong) SDImageCache *imageCache;
@property (nonatomic, strong) NSOperationQueue *imageDownloadQueue;
@end

@implementation AttachmentDownloadManager

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

//MARK - Setup
- (void)commonInit {
    self.imageCache = SDImageCache.sharedImageCache;
    self.imageDownloadQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadQueue.name = @"com.chatObjc.imageDownloadqueue";
    self.imageDownloadQueue.qualityOfService = NSQualityOfServiceUserInteractive;
}

//MARK: - Actions
- (void)downloadAttachmentWithID:(NSString *)ID
                  attachmentName:(NSString *)attachmentName
                  attachmentType:(AttachmentType)attachmentType
                 progressHandler:(ProgressHandler)progressHandler
                  successHandler:(SuccessHandler)successHandler
                    errorHandler:(ErrorHandler)errorHandler {
    if ([self.imageCache imageFromCacheForKey:ID]) {
        UIImage *image = [self.imageCache imageFromCacheForKey:ID];
        successHandler(image, nil, ID);
    } else {
        NSArray *operations = self.imageDownloadQueue.operations;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attachmentID == %@ AND isFinished == %@ AND isExecuting == %@", ID, @NO, @YES];
        AttachmentDownloadOperation *operation = [[operations filteredArrayUsingPredicate:predicate] firstObject];
        
        if (operation) {
            operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        } else {
            
            __weak typeof(self)weakSelf = self;
            
            AttachmentDownloadOperation *operation = [[AttachmentDownloadOperation alloc] initWithAttachmentID:ID attachmentName:attachmentName attachmentType:attachmentType progressHandler:^(CGFloat progress, NSString * _Nonnull ID) {
                progressHandler(progress, ID);
            } successHandler:^(UIImage * _Nullable image, NSURL * _Nullable url, NSString *ID) {
                if (attachmentType == AttachmentTypeImage && image) {
                    UIImage *fixImage = [image fixOrientation];
                    [weakSelf.imageCache storeImage:fixImage forKey:ID toDisk:NO completion:^{
                        successHandler(fixImage, nil, ID);
                    }];
                } else if (attachmentType == AttachmentTypeVideo && url) {
                    [CacheManager.instance getFileWithStringUrl:url.absoluteString completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"failure in the Cache of video, error: %@", error.localizedDescription);
                        } else if (url) {
                            [url getThumbnailImageFromVideoUrlWithCompletion:^(UIImage * _Nullable thumbnailImage) {
                                [weakSelf.imageCache storeImage:thumbnailImage forKey:ID toDisk:NO completion:^{
                                    successHandler(thumbnailImage, url, ID);
                                }];
                            }];
                        }
                    }];
                } else if (attachmentType == AttachmentTypeFile && url) {
                    [CacheManager.instance getFileWithStringUrl:url.absoluteString completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"failure in the Cache of file, error: %@", error.localizedDescription);
                        } else if (url) {
                            [url imageFromPDFfromURLWithCompletion:^(UIImage * _Nullable thumbnailImage) {
                                if (thumbnailImage) {
                                    [weakSelf.imageCache storeImage:thumbnailImage forKey:ID toDisk:NO completion:^{
                                        successHandler(thumbnailImage, url, ID);
                                    }];
                                } else {
                                    successHandler(nil, url, ID);
                                }
                            }]; 
                        }
                    }];
                }
            } errorHandler:^(NSError * _Nonnull error, NSString * _Nonnull ID) {
                errorHandler(error, ID);
            }];
            [self.imageDownloadQueue addOperation:operation];
        }
    }
}

- (void)slowDownloadAttachmentWithID:(NSString *)ID {
    
    NSArray *operations = self.imageDownloadQueue.operations;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attachmentID == %@ AND isFinished == %@ AND isExecuting == %@", ID, @NO, @YES];
    AttachmentDownloadOperation *operation = [[operations filteredArrayUsingPredicate:predicate] firstObject];
    
    if (operation) {
        operation.queuePriority = NSOperationQueuePriorityLow;
    }
}

@end
