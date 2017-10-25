//
//  QMMediaStoreService.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMAttachmentStoreServiceDelegate.h"
#import "QMAttachmentsMemoryStorage.h"
#import "QMCancellableService.h"

/**
 The options for the cache types for attachment. Uses for saving to cache.
 */
typedef NS_OPTIONS(NSInteger, QMAttachmentCacheType) {
    /**
     * Memory cache. QMAttachmentStoreService should save the attachment to the memory cache.
     */
    QMAttachmentCacheTypeMemory = 1 << 0,
    
    /**
     * Disck cache. QMAttachmentStoreService should save the attachment to the disck cache.
     */
    QMAttachmentCacheTypeDisc = 1 << 1
};

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentStoreService : NSObject <QMCancellableService>

/**
 The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality). Default value - 1.0.
 */
@property (nonatomic) CGFloat jpegCompressionQuality;

/**
 Memory storage for attachments.
 */
@property (strong, nonatomic, readonly) QMAttachmentsMemoryStorage *attachmentsMemoryStorage;

/**
 Attachment store service delegate
 */
@property (nonatomic, weak, nullable) id <QMAttachmentStoreServiceDelegate> storeDelegate;

/**
 Initializes an `QMAttachmentStoreService` object with the specified '<QMAttachmentStoreServiceDelegate>'.
 
 @param delegate The instance that confirms @<QMAttachmentStoreServiceDelegate>.
 @return The newly-initialized 'QMAttachmentStoreService'.
 */
- (instancetype)initWithDelegate:(id <QMAttachmentStoreServiceDelegate>)delegate;

/**
 Updates saved 'QBChatAttachment' instance in cache.
 
 @param attachment 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param dialogID The dialog ID.
 */
- (void)updateAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
                dialogID:(NSString *)dialogID;

/**
 Gets cached image from attachment.
 
 @param attachment 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param dialogID  The dialog ID.
 @param completion The block with the cached image.
 */
- (void)cachedImageForAttachment:(QBChatAttachment *)attachment
                       messageID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                      completion:(void(^)(UIImage * _Nullable image))completion;

/**
 Gets `NSData` representation for provided image.
 
 @param image 'UIImage' instance.
 @return `NSData` instance.
 */
- (NSData *)dataForImage:(UIImage *)image;

/**
 Gets cached data and file URL for attachment.
 
 @param attachment 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param dialogID The dialog ID.
 @param completion  If the attachment was founded in the cache, the block will be with fileURL and data parameters set.
 *
 */
- (void)cachedDataForAttachment:(QBChatAttachment *)attachment
                      messageID:(NSString *)messageID
                       dialogID:(NSString *)dialogID
                     completion:(void(^)(NSURL *_Nullable fileURL, NSData *_Nullable data))completion;

/**
 Stores attachment for provided cache type.
 
 @param attachment 'QBChatAttachment' instance.
 @param data 'NSData' instance. If this parameter is nil the data will be taken from attachment's image or local file URL.
 @param cacheType Type of the cache.
 @param messageID The message ID that contains attachment.
 @param dialogID The dialog ID.
 @param completion The block to be invoked when finishes the storing.
 */
- (void)storeAttachment:(QBChatAttachment *)attachment
              withData:(nullable NSData *)data
             cacheType:(QMAttachmentCacheType)cacheType
             messageID:(NSString *)messageID
              dialogID:(NSString *)dialogID
            completion:(nullable dispatch_block_t)completion;

/**
 Gets file URL for saved attachment.
 
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param dialogID The dialog ID.
 @return 'NSURL' instance.
 */
- (nullable NSURL *)fileURLForAttachment:(QBChatAttachment *)attachment
                               messageID:(NSString *)messageID
                                dialogID:(NSString *)dialogID;

/**
 Gets the 'QBChatAttachment'
 
 @param attachmentID The attachment ID.
 @param messageID The message ID that contains attachment.
 @return 'QBChatAttachment' instance if exists.
 */
- (nullable QBChatAttachment *)cachedAttachmentWithID:(NSString *)attachmentID
                                         forMessageID:(NSString *)messageID;

/**
 Gets size for provided dialog ID and message ID.
 
 @param messageID The message ID that contains attachment.
 @param dialogID  The dialog ID.
 
 @return Size
 */
- (NSUInteger)sizeForMessageWithID:(nullable NSString *)messageID
                          dialogID:(NSString *)dialogID;


/**
 Clears all data related to attachments for specified dialogID and messages ID's array from provided cache type.
 
 @param cacheType Type of the cache.
 @param completion The block to be invoked when finishes the cleaning.
 */
- (void)clearCacheForType:(QMAttachmentCacheType)cacheType
               completion:(nullable dispatch_block_t)completion;

/**
 Clears all data related to attachments for specified dialogID from provided cache type.
 
 @param dialogID The dialog ID.
 @param cacheType Type of the cache.
 @param completion The block to be invoked when finishes the cleaning.
 */
- (void)clearCacheForDialogWithID:(NSString *)dialogID
                        cacheType:(QMAttachmentCacheType)cacheType
                       completion:(nullable dispatch_block_t)completion;

/**
 Clears all data related to attachments for specified dialogID and message ID from provided cache type.
 
 @param messageID The message ID that contains attachment.
 @param dialogID The dialog ID.
 @param cacheType Type of the cache.
 @param completion The block to be invoked when finishes the cleaning.
 */
- (void)clearCacheForMessageWithID:(NSString *)messageID
                          dialogID:(NSString *)dialogID
                         cacheType:(QMAttachmentCacheType)cacheType
                        completion:(nullable dispatch_block_t)completion;

/**
 Clears all data related to attachments for specified dialogID and messages ID's array from provided cache type.
 
 @param messagesIDs An instance of NSArray, containing messageIDs.
 @param dialogID The dialog ID.
 @param cacheType Type of the cache.
 @param completion The block to be invoked when finishes the cleaning.
 */
- (void)clearCacheForMessagesWithIDs:(NSArray <NSString *> *)messagesIDs
                            dialogID:(NSString *)dialogID
                           cacheType:(QMAttachmentCacheType)cacheType
                          completion:(nullable dispatch_block_t)completion;
@end

NS_ASSUME_NONNULL_END
