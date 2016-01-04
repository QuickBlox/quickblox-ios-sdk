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
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message;

/**
 *  Is called when chat attachment service did change loading progress for some attachment.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param progress changed value of progress min 0.0, max 1.0
 *  @param attachment loaded QBChatAttachment
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment;

/**
 *  Is called when chat attachment service did change Uploading progress for attachment in message.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService QMChatAttachmentService instance
 *  @param progress              changed value of progress min 0.0, max 1.0
 *  @param messageID             ID of message that contains attachment
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message;

@end

/**
 *  Chat attachment service
 */
@interface QMChatAttachmentService : NSObject

/**
 *  Chat attachment service delegate
 */
@property (nonatomic, weak) id<QMChatAttachmentServiceDelegate> delegate;

/**
 *  Send message with attachment to dialog
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param image        Attachment image
 *  @param completion   Send message result
 *
 *  @warning *Deprecated in QMServices 0.3.2:* Use '[chatService sendAttachmentMessage:toDialog:withAttachmentImage:completion:]' instead.
 */
- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedImage:(UIImage *)image completion:(void(^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.2. Use '[chatService sendAttachmentMessage:toDialog:withAttachmentImage:completion:]' instead.");

/**
 *  Upload and send attachment message to dialog.
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param image        Attachment image
 *  @param completion   Send message result
 */
- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedImage:(UIImage *)image completion:(QBChatCompletionBlock)completion;

/**
 *  Get image by attachment
 *
 *  @param attachment      QBChatAttachment instance
 *  @param completion      Fetch image result
 *
 *  @warning *Deprecated in QMServices 0.3.2:* Use 'getImageForAttachmentMessage:completion:' instead.
 */
- (void)getImageForChatAttachment:(QBChatAttachment *)attachment completion:(void (^)(NSError *error, UIImage *image))completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.2. Use 'getImageForAttachmentMessage:completion:' instead.");

/**
 *  Get image by attachment message.
 *
 *  @param attachmentMessage      message with attachment
 *  @param completion             fetched image or error if failed
 */
- (void)getImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion;

@end
