//
//  QBChatAttachment+QMFactory.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import <Quickblox/Quickblox.h>
#import "QBChatAttachment+QMCustomParameters.h"

NS_ASSUME_NONNULL_BEGIN

@interface QBChatAttachment (QMFactory)

+ (instancetype)initWithName:(nullable NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type;

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
