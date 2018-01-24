//
//  QBChatAttachment+QMFactory.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMFactory.h"
#import "QBChatAttachment+QMCustomData.h"



static NSString * const kQMLocationLatitudeKey = @"lat";
static NSString * const kQMLocationLongitudeKey = @"lng";

static NSString *const kQMAttachmentContentTypeM4AAudio = @"audio/x-m4a";
static NSString *const kQMAttachmentContentTypeMP4Video = @"video/mp4";

@implementation QBChatAttachment (QMFactory)

- (instancetype)initWithName:(NSString *)name
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
    
    return [[self alloc] initWithName:@"Video attachment"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeMP4Video
               attachmentType:kQMAttachmentTypeVideo];
}

+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL {
    
    NSParameterAssert(fileURL);
    
    return [[self alloc] initWithName:@"Voice message"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeM4AAudio
               attachmentType:kQMAttachmentTypeAudio];
}

+ (instancetype)locationAttachmentWithCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatAttachment *locationAttachment = [[self alloc] initWithName:@"Location"
                                                              fileURL:nil
                                                          contentType:kQMAttachmentTypeLocation
                                                       attachmentType:kQMAttachmentTypeLocation];
    
    locationAttachment.context[kQMLocationLatitudeKey] =
    [NSString stringWithFormat:@"%lf", locationCoordinate.latitude];
    locationAttachment.context[kQMLocationLongitudeKey] =
    [NSString stringWithFormat:@"%lf", locationCoordinate.longitude];
    [locationAttachment synchronize];
    
    return locationAttachment;
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image {
    
    NSParameterAssert(image);
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    NSString *contentType = [NSString stringWithFormat:@"image/%@", hasAlpha ? @"png" : @"jpg"];
    
    QBChatAttachment *attachment = [[self alloc] initWithName:@"Image attachment"
                                              fileURL:nil
                                          contentType:contentType
                                       attachmentType:kQMAttachmentTypeImage];
    attachment.image = image;
    
    return attachment;
}



@end
