//
//  AttachmentDownloadManager.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AttachmentDownloadManager.h"
#import "AttachmentDownloadOperation.h"
#import "ImageCache.h"

@interface AttachmentDownloadManager()
@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic, strong) NSOperationQueue *imageDownloadQueue;
@end

@implementation AttachmentDownloadManager

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = ImageCache.instance;
        self.imageDownloadQueue = [[NSOperationQueue alloc] init];
        self.imageDownloadQueue.name = @"com.chatObjc.imageDownloadqueue";
        self.imageDownloadQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    }
    return self;
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
            AttachmentDownloadOperation *operation = [[AttachmentDownloadOperation alloc] initWithAttachmentID:ID attachmentName:attachmentName attachmentType:attachmentType progressHandler:^(CGFloat progress, NSString * _Nonnull ID) {
                progressHandler(progress, ID);
            } successHandler:^(UIImage * _Nullable image, NSURL * _Nullable url, NSString *ID) {
                if (image) {
                    successHandler(image, nil, ID);
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
