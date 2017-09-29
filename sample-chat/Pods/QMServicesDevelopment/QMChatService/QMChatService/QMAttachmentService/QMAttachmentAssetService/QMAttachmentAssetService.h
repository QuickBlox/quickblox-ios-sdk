//
//  QMAttachmentAssetService.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 2/22/17.
//
//

#import <Foundation/Foundation.h>
#import "QMAssetLoader.h"
#import "QMMediaBlocks.h"
#import "QMCancellableService.h"

@interface QMAttachmentAssetService : NSObject <QMCancellableService>

/**
 Loads asset from attachment's local file or remote URL.
 
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)loadAssetForAttachment:(QBChatAttachment *)attachment
                     messageID:(NSString *)messageID
                    completion:(QMAttachmentAssetLoaderCompletionBlock)completion;
@end

