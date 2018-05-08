//
//  QMChatAttachmentService.h
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatTypes.h"

#import "QMAttachmentStoreService.h"
#import "QMAttachmentAssetService.h"
#import "QMAttachmentContentService.h"
#import "QMCancellableService.h"
#import "QMChatTypes.h"

@class QMChatService;
@protocol QMChatAttachmentServiceDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentOperation : NSBlockOperation

@property (copy, nonatomic) NSString *identifier;
@property QBChatAttachment *attachment;
@property NSError *error;

@property (copy, nonatomic) dispatch_block_t cancelBlock;

@end

/**
 *  Chat attachment service
 */
@interface QMChatAttachmentService : NSObject

/**
 'QMAttachmentStoreService' instance.
 */
@property (nonatomic, strong, readonly) QMAttachmentStoreService *storeService;

/**
 'QMAttachmentContentService' instance.
 */
@property (nonatomic, strong, readonly) QMAttachmentContentService *contentService;

/**
 'QMAttachmentAssetService' instance.
 */
@property (nonatomic, strong, readonly) QMAttachmentAssetService *assetService;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/**
 Initializes an `QMChatAttachmentService` object with the specified store, content and asset service.
 
 @param storeService The `QMAttachmentStoreService` instance.
 @param contentService The `QMAttachmentContentService` instance.
 @param assetService The `QMAttachmentAssetService` instance.
 
 @return The newly-initialized QMChatAttachmentService.
 */
- (instancetype)initWithStoreService:(QMAttachmentStoreService *)storeService
                      contentService:(QMAttachmentContentService *)contentService
                        assetService:(QMAttachmentAssetService *)assetService NS_DESIGNATED_INITIALIZER;

/**
 Returns the current status of the attachment message.
 
 @param message QBChatMessage instance, that contains attachment.
 @return The current status of the attachment message.
 */
- (QMMessageAttachmentStatus)attachmentStatusForMessage:(QBChatMessage *)message;

/**
 Gets the attachment from the attachment message.
 
 @param attachmentID The ID of the 'QBChatAttachment' instance.
 @param message QBChatMessage instance, that contains attachment.
 @param progressBlock Block with changed value of progress. Min 0.0, max 1.0.
 @param completionBlock Completion block with 'QMAttachmentOperation' instance.
 */
- (void)attachmentWithID:(NSString *)attachmentID
                 message:(QBChatMessage *)message
           progressBlock:(nullable QMAttachmentProgressBlock)progressBlock
              completion:(nullable void(^)(QMAttachmentOperation *op))completionBlock;
/**
 Indicates whether the attachment, or its URL, can be used to play.
 
 @abstract        Returns YES if attachment is playable.
 
 @param attachment 'QBChatAttachment' instance
 @param message    'QBChatMessage' instance, that contains attachment.
 @return YES or NO.
 */
- (BOOL)attachmentIsReadyToPlay:(QBChatAttachment *)attachment
                        message:(QBChatMessage *)message;

/**
 Cancels queued or executing operations.
 
 @param messageID The message ID that contains attachment.
 */
- (void)cancelOperationsWithMessageID:(NSString *)messageID;

/**
 Removes all data related to attachments from the disk and the cache.
 */
- (void)removeAllMediaFiles;

/**
 Removes all data related to attachments for the specified dialog with ID from the disk and the cache.
 
 @param dialogID The dialog ID.
 */
- (void)removeMediaFilesForDialogWithID:(NSString *)dialogID;

/**
 Removes all data related to attachments for the specified dialogID and messageID from the disk and cache.
 
 @param messageID The message ID that contains attachment.
 @param dialogID  The dialog ID.
 */
- (void)removeMediaFilesForMessageWithID:(NSString *)messageID
                                dialogID:(NSString *)dialogID;


/**
 Removes all data related to attachments for specified dialogID and messages ID's array from disk and cache.
 
 @param messagesIDs An instance of NSArray, containing messageIDs.
 @param dialogID The dialog ID.
 */
- (void)removeMediaFilesForMessagesWithID:(NSArray<NSString *> *)messagesIDs
                                 dialogID:(NSString *)dialogID;

/**
 Directs service to load the values for asset from attachment.
 
 @param attachment 'QBChatAttachment' instance.
 @param message  QBChatMessage instance, that contains attachment.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)prepareAttachment:(QBChatAttachment *)attachment
                  message:(QBChatMessage *)message
               completion:(QMAttachmentAssetLoaderCompletionBlock)completion;

/**
 *  Adds delegate (Multicast)
 *
 *  @param delegate An instance that confirmes QMChatAttachmentServiceDelegate protocol
 */
- (void)addDelegate:(id <QMChatAttachmentServiceDelegate>)delegate;

/**
 *  Removes delegate from observed list
 *
 *  @param delegate An instance that confirmes QMChatAttachmentServiceDelegate protocol
 */
- (void)removeDelegate:(id <QMChatAttachmentServiceDelegate>)delegate;

/**
 *  Chat attachment service delegate
 *
 *  @warning *Deprecated in QMServices 0.4.7:* Use 'addDelegate:' instead.
 */
@property (nonatomic, weak, nullable) id<QMChatAttachmentServiceDelegate> delegate
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.7. Use 'addDelegate:' instead.");

/**
 *  Uploads and sends attachment message to dialog.
 *
 *  @param message      QBChatMessage instance, that contains attachment.
 *  @param dialog       QBChatDialog instance.
 *  @param chatService  QMChatService instance.
 *  @param image        Attachment image.
 *  @param completion   Upload message result.
 *
 *  @warning *Deprecated in QMServices 0.5: * Use 'uploadAndSendAttachmentMessage:toDialog:withChatService:attachment:completion:' instead.
 */
- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                     withAttachedImage:(UIImage *)image
                            completion:(nullable QBChatCompletionBlock)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.5 Use 'uploadAndSendAttachmentMessage:toDialog:withChatService:attachment:completion:' instead.");

/**
 *  Gets the image from the attachment message.
 *
 *  @param attachmentMessage Message with attachment.
 *  @param completion        Fetched image or error if failed.
 */
- (void)imageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                       completion:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))completion;

/**
 *  Gets local image for attachment message.
 *
 *  @param attachmentMessage      Message with attachment.
 *  @param completion             Local image or nil if no image.
 */
- (void)localImageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                            completion:(void(^)(UIImage * _Nullable image))completion;

/**
 *  Uploads and sends attachment message to dialog.
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param attachment   QBChatAttachment instance
 *  @param completion   Send message result
 */

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                            attachment:(QBChatAttachment *)attachment
                            completion:(nullable QBChatCompletionBlock)completion;
@end

@protocol QMChatAttachmentServiceDelegate <NSObject>

@optional

/**
 *  Is called when attachment service did change current state of the attachment.
 *  Please see QMMessageAttachmentState for additional info.
 *
 *  @param chatAttachmentService The 'QMChatAttachmentService' instance.
 *  @param status The current status of the attachment messsage.
 *  @param message QBChatMessage instance, that contains attachment.
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService
    didChangeAttachmentStatus:(QMMessageAttachmentStatus)status
                   forMessage:(QBChatMessage *)message;

/**
 *  Is called when chat attachment service did change loading progress for some attachment.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param progress changed value of progress min 0.0, max 1.0
 *  @param attachment loaded QBChatAttachment
 *
 *  @warning *Deprecated in QMServices 0.5:* Use 'chatAttachmentService:didChangeLoadingProgress:forMessage:attachment:' instead.
 */

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService
     didChangeLoadingProgress:(CGFloat)progress
            forChatAttachment:(QBChatAttachment *)attachment

DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.5 Use 'chatAttachmentService:didChangeLoadingProgress:forMessage:attachment:' instead.");

/**
 *  Is called when chat attachment service did change Uploading progress for attachment in message.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService QMChatAttachmentService instance.
 *  @param progress              Changed value of progress. Min 0.0, max 1.0.
 *  @param message               QBChatMessage instance, that contains attachment.
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService
   didChangeUploadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message;

/**
 *  Is called when chat attachment service did change downloading progress for some attachment.
 *  Used for display downloading progress.
 *
 *  @param chatAttachmentService 'QMChatAttachmentService' instance.
 *  @param progress              Changed value of progress. Min 0.0, max 1.0
 *  @param message               QBChatMessage instance, that contains attachment.
 *  @param attachment            'QBChatAttachment' instance that uploading.
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService
     didChangeLoadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message
                   attachment:(QBChatAttachment *)attachment;


@end

NS_ASSUME_NONNULL_END
