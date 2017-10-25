//
//  QMMediaWebService.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 6/14/17.
//

#import <Foundation/Foundation.h>
#import "QMMediaUploadService.h"
#import "QMMediaDownloadService.h"

@protocol QMAttachmentContentServiceDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentContentService : NSObject <QMCancellableService>

/**
 The chat attachment content service delegate
 */
@property (weak, nonatomic) id <QMAttachmentContentServiceDelegate> delegate;

/**
 Indicates whether the attachment is downloading.
 
 @param messageID The message ID that contains attachment.
 @return YES if the attachment is downloading, otherwise NO.
 */
- (BOOL)isDownloadingMessageWithID:(NSString *)messageID;

/**
 Indicates whether the attachment is uploading.
 
 @param messageID The message ID that contains attachment.
 @return YES if the attachment is uploading, otherwise NO.
 */
- (BOOL)isUploadingMessageWithID:(NSString *)messageID;

/**
 Downloads the attachment with the file URL.
 
 @param attachmentID The 'QBChatAttachment' instance ID.
 @param message The message that contains attachment.
 @param progressBlock A block called repeatedly while the attachment is downloading.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)downloadAttachmentWithID:(NSString *)attachmentID
                         message:(QBChatMessage *)message
                   progressBlock:(QMAttachmentProgressBlock)progressBlock
                 completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion;

/**
 Uploads the attachment with the data.
 
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param data The data representation of the attachment.
 @param progressBlock The block called repeatedly while the attachment is uploading.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
                withData:(NSData *)data
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion;


/**
 Uploads the attachment with the file URL.
 
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param fileURL The URL of the attachment data on disk.
 @param progressBlock The block called repeatedly while the attachment is uploading.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
             withFileURL:(NSURL *)fileURL
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion;

/**
 Returns the progress for message ID.
 
 @param messageID The message ID that contains attachment.
 */
- (CGFloat)progressForMessageWithID:(NSString *)messageID;

/**
 Cancels queued or executing download operations.
 */
- (void)cancelDownloadOperations;

@end

@protocol QMAttachmentContentServiceDelegate <NSObject>

@optional

/**
 Asks the delegate if the content service should download the attachment.
 
 @param contentService The 'QMAttachmentContentService' instance.
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @return  YES if the content service should download the attachment; otherwise, NO.
 */
- (BOOL)attachmentContentService:(QMAttachmentContentService *)contentService
        shouldDownloadAttachment:(QBChatAttachment *)attachment
                       messageID:(NSString *)messageID;

@end

NS_ASSUME_NONNULL_END
