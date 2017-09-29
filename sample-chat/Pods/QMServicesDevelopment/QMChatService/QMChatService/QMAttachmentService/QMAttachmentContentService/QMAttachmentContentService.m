//
//  QMMediaWebService.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 6/14/17.
//

#import "QMAttachmentContentService.h"
#import "QMMediaDownloadService.h"
#import "QMMediaUploadService.h"

@interface QMAttachmentContentService()

@property (nonatomic, strong) QMMediaUploadService *uploader;
@property (nonatomic, strong) QMMediaDownloadService *downloader;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *messagesWebProgress;
@end

@implementation QMAttachmentContentService

- (instancetype)init {
    
    QMMediaUploadService *uploader = [QMMediaUploadService new];
    QMMediaDownloadService *downloader = [QMMediaDownloadService new];
    
    return [self initWithUploader:uploader downloader:downloader];
}

- (instancetype)initWithUploader:(QMMediaUploadService *)uploader
                      downloader:(QMMediaDownloadService *)downloader {
    
    if (self = [super init]) {
        
        _messagesWebProgress = [NSMutableDictionary dictionary];
        _uploader = uploader;
        _downloader = downloader;
    }
    return self;
}


- (void)downloadAttachmentWithID:(NSString *)attachmentID
                         message:(QBChatMessage *)message
                   progressBlock:(QMAttachmentProgressBlock)progressBlock
                 completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.downloader downloadAttachmentWithID:attachmentID
                                    messageID:message.ID
                                progressBlock:^(float progress) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    [strongSelf setProgress:progress messageID:message.ID];
                                    progressBlock(progress);
                                }
                              completionBlock:completion];
}


- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
                withData:(NSData *)data
           progressBlock:(QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *uploadOperation))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.uploader uploadAttachment:attachment
                          messageID:messageID
                           withData:data
                      progressBlock:^(float progress) {
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf setProgress:progress messageID:messageID];
                          progressBlock(progress);
                      }
                    completionBlock:completion];
}

- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
             withFileURL:(NSURL *)fileURL
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.uploader uploadAttachment:attachment
                          messageID:messageID
                        withFileURL:fileURL
                      progressBlock:^(float progress) {
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf setProgress:progress messageID:messageID];
                          progressBlock(progress);
                      }
                    completionBlock:completion];
}

- (CGFloat)progressForMessageWithID:(NSString *)messageID {
    return _messagesWebProgress[messageID].floatValue;
}

- (void)setProgress:(CGFloat)progress messageID:(NSString *)messageID {
    _messagesWebProgress[messageID] = @(progress);
}

//MARK: - QMCancellableService

- (void)cancelOperationWithID:(NSString *)operationID {
    [self.messagesWebProgress removeObjectForKey:operationID];
    [self.downloader cancelOperationWithID:operationID];
    [self.uploader cancelOperationWithID:operationID];
    self.messagesWebProgress[operationID] = nil;
}

- (BOOL)isDownloadingMessageWithID:(NSString *)messageID {
    return [self.downloader isDownloadingMessageWithID:messageID];
}

- (BOOL)isUploadingMessageWithID:(NSString *)messageID {
    return [self.uploader isUploadingMessageWithID:messageID];
}

- (void)cancelDownloadOperations {
    [self.downloader cancelAllOperations];
}

- (void)cancelAllOperations {
    
    [self.downloader cancelAllOperations];
    [self.uploader cancelAllOperations];
}

@end
