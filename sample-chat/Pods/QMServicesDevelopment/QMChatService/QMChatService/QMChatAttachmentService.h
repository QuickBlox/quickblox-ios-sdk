//
//  QMChatAttachmentService.h
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatTypes.h"

@class QMChatService;
@class QMChatAttachmentService;

@protocol QMChatAttachmentServiceDelegate <NSObject>

/**
 *  Is called when attachment service did change attachment status for some message.
 *  Please see QMMessageAttachmentStatus for additional info.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param status new status
 *  @param message new status owner QBChatMessage
 */
- (void)chatAttachmentService:(QB_NONNULL QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QB_NONNULL QBChatMessage *)message;

/**
 *  Is called when chat attachment service did change loading progress for some attachment.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param progress changed value of progress min 0.0, max 1.0
 *  @param attachment loaded QBChatAttachment
 */
- (void)chatAttachmentService:(QB_NONNULL QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QB_NONNULL QBChatAttachment *)attachment;

/**
 *  Is called when chat attachment service did change Uploading progress for attachment in message.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService QMChatAttachmentService instance
 *  @param progress              changed value of progress min 0.0, max 1.0
 *  @param messageID             ID of message that contains attachment
 */
- (void)chatAttachmentService:(QB_NONNULL QMChatAttachmentService *)chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QB_NONNULL QBChatMessage *)message;

@end

/**
 *  Chat attachment service
 */
@interface QMChatAttachmentService : NSObject

/**
 *  Chat attachment service delegate
 */
@property (nonatomic, weak, QB_NULLABLE) id<QMChatAttachmentServiceDelegate> delegate;

/**
 *  Upload and send attachment message to dialog.
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param image        Attachment image
 *  @param completion   Send message result
 */
- (void)uploadAndSendAttachmentMessage:(QB_NONNULL QBChatMessage *)message toDialog:(QB_NONNULL QBChatDialog *)dialog withChatService:(QB_NONNULL QMChatService *)chatService withAttachedImage:(QB_NONNULL UIImage *)image completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Get image by attachment message.
 *
 *  @param attachmentMessage      message with attachment
 *  @param completion             fetched image or error if failed
 */
- (void)getImageForAttachmentMessage:(QB_NONNULL QBChatMessage *)attachmentMessage completion:(void(^QB_NULLABLE_S)(NSError *QB_NULLABLE_S error, UIImage *QB_NULLABLE_S image))completion;

@end
