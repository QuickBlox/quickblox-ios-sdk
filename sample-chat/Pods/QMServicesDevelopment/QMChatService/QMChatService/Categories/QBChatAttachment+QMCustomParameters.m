//
//  QBChatAttachment+QMCustomParameters.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMCustomParameters.h"
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QMSLog.h"

/**
 *  Attachment keys
 */
NSString  *kQMAttachmentWidthKey = @"width";
NSString  *kQMAttachmentHeightKey = @"height";
NSString  *kQMAttachmentDurationKey = @"duration";
NSString  *kQMAttachmentSizeKey = @"size";
NSString  *kQMAttachmentContentTypeKey = @"content-type";

@implementation QBChatAttachment (QMCustomParameters)

@dynamic fileExtension;

- (NSString *)fileExtension {
    
    CFStringRef MIMEType = (__bridge CFStringRef)self.contentType;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    return (__bridge_transfer NSString *)extension;
}

- (NSString *)contentType {
    
    NSString *contentType = self[kQMAttachmentContentTypeKey];
    
    if (!contentType) {
        contentType = [self defaultContentType];
        self[kQMAttachmentContentTypeKey] = contentType;
    }
    
    return contentType;
}

- (void)setContentType:(NSString *)contentType {
    
    if (![self[kQMAttachmentContentTypeKey] isEqualToString:contentType]) {
        self[kQMAttachmentContentTypeKey] = contentType;
    }
}

- (NSURL *)localFileURL {
    return objc_getAssociatedObject(self, @selector(localFileURL));
}

- (void)setLocalFileURL:(NSURL *)localFileURL {
    objc_setAssociatedObject(self, @selector(localFileURL), localFileURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)image {
    return objc_getAssociatedObject(self, @selector(image));
}

- (void)setImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (QMAttachmentType)attachmentType {
    
    if ([[self tAttachmentType] integerValue] == 0) {
        
        QMAttachmentType attachmentType = [self attachmentTypeFromString:self.type];
        [self setAttachmentType:attachmentType];
    }
    
    return [[self tAttachmentType] integerValue];
}

- (void)setAttachmentType:(QMAttachmentType)attachmentType {
    [self setTAttachmentType:@(attachmentType)];
}


- (NSNumber *)tAttachmentType {
    
    return objc_getAssociatedObject(self, @selector(tAttachmentType));
}

- (void)setTAttachmentType:(NSNumber *)attachmentTypeNumber {
    
    objc_setAssociatedObject(self, @selector(tAttachmentType), attachmentTypeNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSInteger)width {
    
    return [self[kQMAttachmentWidthKey] integerValue];
}

- (void)setWidth:(NSInteger)width {
    
    if (self.width != width) {
        self[kQMAttachmentWidthKey] = [NSString stringWithFormat:@"%ld",(unsigned long)width];
    }
}

- (NSInteger)height {
    
    return [self[kQMAttachmentHeightKey] integerValue];
}

- (void)setHeight:(NSInteger)height {
    
    if (self.height != height) {
        self[kQMAttachmentHeightKey] = [NSString stringWithFormat:@"%ld",(unsigned long)height];
    }
}

- (NSInteger)size {
    
    return [self[kQMAttachmentSizeKey] integerValue];
}

- (void)setSize:(NSInteger)size {
    
    if (self.size != size) {
        self[kQMAttachmentSizeKey] = [NSString stringWithFormat:@"%ld",(unsigned long)size];
    }
}

- (NSInteger)duration {
    
    return [self[kQMAttachmentDurationKey] integerValue];
}

- (void)setDuration:(NSInteger)duration {
    
    if (self.duration != duration) {
        self[kQMAttachmentDurationKey] = [NSString stringWithFormat:@"%ld",(unsigned long)duration];
    }
}

- (NSString *)defaultContentType {
    
    NSString *contentType = nil;
    
    QMAttachmentType attachmentType = [self attachmentTypeFromString:self.type];
    
    switch (attachmentType) {
        case QMAttachmentContentTypeAudio:
            contentType = @"audio/mp4";
            break;
            
        case QMAttachmentContentTypeVideo:
            contentType = @"video/mp4";
            break;
            
        case QMAttachmentContentTypeImage:
            contentType = @"image/png";
            break;
            
        default:
            QMSLog(@"ERROR: 'Content type' is not provided for custom attachment: %@");
            break;
    }
    
    return contentType;
}

- (NSURL *)remoteURL {
    
    return [self remoteURLWithToken:YES];
}

- (NSURL *)remoteURLWithToken:(BOOL)withToken {
    
    if (self.ID.length == 0) {
        return nil;
    }
    
    NSString *apiEndpoint = [QBSettings apiEndpoint];
    
    NSURLComponents *components =
    [NSURLComponents componentsWithURL:[NSURL URLWithString:apiEndpoint]
               resolvingAgainstBaseURL:false];
    
    components.path = [NSString stringWithFormat:@"/blobs/%@", self.ID];
    
    if (withToken) {
        components.query = [NSString stringWithFormat:@"token=%@",[QBSession currentSession].sessionDetails.token];
    }
    return components.URL;
}

- (BOOL)isPrepared {
    
    switch (self.attachmentType) {
            
        case QMAttachmentContentTypeAudio:
            return self.duration > 0;
        case QMAttachmentContentTypeImage:
            return YES;
            break;
        case QMAttachmentContentTypeVideo:
            return self.image != nil && self.duration > 0;
            break;
        case QMAttachmentContentTypeCustom:
            return YES;
            break;
        default:
            break;
    }
}

//MARK: Helpers

- (QMAttachmentType)attachmentTypeFromString:(NSString *)type {
    
    QMAttachmentType attachmentType = QMAttachmentContentTypeCustom;
    
    if ([self.type isEqualToString:@"audio"]) {
        attachmentType = QMAttachmentContentTypeAudio;
    }
    else if ([self.type isEqualToString:@"video"]) {
        attachmentType = QMAttachmentContentTypeVideo;
    }
    else if ([self.type isEqualToString:@"image"] ||
             [self.type isEqualToString:@"photo"]) {
        
        attachmentType = QMAttachmentContentTypeImage;
    }
    
    return attachmentType;
}

@end
