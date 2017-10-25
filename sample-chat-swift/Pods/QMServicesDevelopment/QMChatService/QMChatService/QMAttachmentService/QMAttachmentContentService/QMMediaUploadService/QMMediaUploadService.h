//
//  QMMediaUploadService.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/9/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMediaBlocks.h"
#import "QMAsynchronousOperation.h"
#import "QMCancellableService.h"


NS_ASSUME_NONNULL_BEGIN

@interface QMUploadOperation : QMAsynchronousOperation

@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSString *attachmentID;

@end

@interface QMMediaUploadService : NSObject <QMCancellableService>

- (void)uploadAttachment:(QBChatAttachment *)attachment
                                 messageID:(NSString *)messageID
                                  withData:(NSData *)data
                             progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion;


- (void)uploadAttachment:(QBChatAttachment *)attachment
                                 messageID:(NSString *)messageID
                               withFileURL:(NSURL *)fileURL
                                   progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
                                 completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion;

- (BOOL)isUploadingMessageWithID:(NSString *)messageID;

@end
NS_ASSUME_NONNULL_END
