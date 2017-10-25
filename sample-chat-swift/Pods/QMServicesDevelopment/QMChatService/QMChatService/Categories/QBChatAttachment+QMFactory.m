//
//  QBChatAttachment+QMFactory.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMFactory.h"

static NSString *const kQMAttachmentTypeAudio = @"audio";
static NSString *const kQMAttachmentTypeImage = @"image";
static NSString *const kQMAttachmentTypeVideo = @"video";

static NSString *const kQMAttachmentContentTypeAudio = @"audio/mp4";
static NSString *const kQMAttachmentContentTypeVideo = @"video/mp4";

@implementation QBChatAttachment (QMFactory)

+ (instancetype)initWithName:(nullable NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type {
    
    QBChatAttachment *attachment = [QBChatAttachment new];
    
    attachment.type = type;
    attachment.name = name;
    attachment.localFileURL = fileURL;
    attachment.contentType = contentType;
    
    return attachment;
}

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)fileURL {
    
    NSParameterAssert(fileURL);
    
    return [self initWithName:@"Video attachment"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeVideo
               attachmentType:kQMAttachmentTypeVideo];
}

+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL {
    
    NSParameterAssert(fileURL);
    
    return [self initWithName:@"Voice message"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeAudio
               attachmentType:kQMAttachmentTypeAudio];
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image {
    
    NSParameterAssert(image);
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    NSString *contentType = [NSString stringWithFormat:@"image/%@", hasAlpha ? @"png" : @"jpg"];
    
    QBChatAttachment *attachment = [self initWithName:@"Image attachment"
                                              fileURL:nil
                                          contentType:contentType
                                       attachmentType:kQMAttachmentTypeImage];
    attachment.image = image;
    
    return attachment;
}

@end
