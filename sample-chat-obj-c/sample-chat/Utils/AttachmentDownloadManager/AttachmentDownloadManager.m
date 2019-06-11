//
//  AttachmentDownloadManager.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadManager.h"
#import "AttachmentDownloadOperation.h"
#import "SDImageCache.h"

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
                 progressHandler:(ProgressHandler)progressHandler
                  successHandler:(SuccessHandler)successHandler
                    errorHandler:(ErrorHandler)errorHandler {
    if ([self.imageCache imageFromCacheForKey:ID]) {
        UIImage *image = [self.imageCache imageFromCacheForKey:ID];
        successHandler(image, ID);
    } else {
        NSArray *operations = self.imageDownloadQueue.operations;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attachmentID == %@ AND isFinished == %@ AND isExecuting == %@", ID, @NO, @YES];
        AttachmentDownloadOperation *operation = [[operations filteredArrayUsingPredicate:predicate] firstObject];
        
        if (operation) {
            operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        } else {
            
            __weak typeof(self)weakSelf = self;
            
            AttachmentDownloadOperation *operation = [[AttachmentDownloadOperation alloc] initWithAttachmentID:ID progressHandler:^(CGFloat progress, NSString * _Nonnull ID) {
                progressHandler(progress, ID);
            } successHandler:^(UIImage * _Nonnull image, NSString * _Nonnull ID) {
                [weakSelf.imageCache storeImage:image forKey:ID toDisk:NO completion:^{
                    successHandler(image, ID);
                }];
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
