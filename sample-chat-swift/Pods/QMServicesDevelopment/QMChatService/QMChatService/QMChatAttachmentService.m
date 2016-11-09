//
//  QMChatAttachmentService.m
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatAttachmentService.h"
#import "QMChatService.h"
#import "QBChatMessage+QMCustomParameters.h"

#import "QMSLog.h"

@interface QMChatAttachmentService()

@property (nonatomic, strong) NSMutableDictionary *attachmentsStorage;

@end

static NSString* attachmentCacheDir() {
    
    static NSString *attachmentCacheDirString;
    
    if (!attachmentCacheDirString) {
        
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        attachmentCacheDirString = [cacheDir stringByAppendingPathComponent:@"Attachment"];
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            if (![[NSFileManager defaultManager] fileExistsAtPath:attachmentCacheDirString]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:attachmentCacheDirString withIntermediateDirectories:NO attributes:nil error:nil];
            }
        });
    }
    
    return attachmentCacheDirString;
}

static NSString* attachmentPath(QBChatAttachment *attachment) {
    
    return [attachmentCacheDir() stringByAppendingPathComponent:[NSString stringWithFormat:@"attachment-%@", attachment.ID]];
}

@implementation QMChatAttachmentService

- (instancetype)init {
    
    if (self = [super init]) {
        self.attachmentsStorage = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                     withAttachedImage:(UIImage *)image
                            completion:(QBChatCompletionBlock)completion {
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading forMessage:message];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest TUploadFile:imageData fileName:@"attachment" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        QBChatAttachment *attachment = [QBChatAttachment new];
        attachment.type = @"image";
        attachment.ID = blob.UID;
        attachment.url = [blob privateUrl];
        
        message.attachments = @[attachment];
        message.text = @"Attachment image";
        
        [strongSelf saveImageData:imageData chatAttachment:attachment error:nil];
        strongSelf.attachmentsStorage[attachment.ID] = image;
        
        [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:message];
        
        [chatService sendMessage:message type:QMMessageTypeText toDialog:dialog saveToHistory:YES saveToStorage:YES completion:completion];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(chatAttachmentService:didChangeUploadingProgress:forMessage:)]) {
            [strongSelf.delegate chatAttachmentService:strongSelf didChangeUploadingProgress:status.percentOfCompletion forMessage:message];
        }
        
    } errorBlock:^(QBResponse *response) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:message];
        
        if (completion) {
            completion(response.error.error);
        }
    }];
}

- (void)imageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion {
    
    if (attachmentMessage.attachmentStatus == QMMessageAttachmentStatusLoading || attachmentMessage.attachmentStatus == QMMessageAttachmentStatusError) {
        return;
    }
    
    QBChatAttachment *attachment = [attachmentMessage.attachments firstObject];
    
    // checking attachment in storage
    if ([self.attachmentsStorage objectForKey:attachment.ID] != nil) {
        if (completion) completion(nil, [self.attachmentsStorage objectForKey:attachment.ID]);
        return;
    }
    
    // checking attachment in cache
    NSString *path = attachmentPath(attachment);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            
            if (image != nil) {
                [self.attachmentsStorage setObject:image forKey:attachment.ID];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error, image);
            });
        });
        
        return;
    }
    
    
    
    // loading attachment from server
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading forMessage:attachmentMessage];
    
    NSString *attachmentID = attachment.ID;
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([attachmentID rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
    
        __weak __typeof(self)weakSelf = self;
        [QBRequest downloadFileWithID:attachmentID.integerValue successBlock:^(QBResponse *response, NSData *fileData) {
            __typeof(weakSelf)strongSelf = weakSelf;
            
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [strongSelf saveImageData:fileData chatAttachment:attachment error:&error];
            
            if (image != nil) {
                
                strongSelf.attachmentsStorage[attachment.ID] = image;
            }
            
            [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:attachmentMessage];
            
            if (completion) {
                completion(error, image);
            }
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [strongSelf.delegate chatAttachmentService:strongSelf didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if (response.status == QBResponseStatusCodeNotFound) {
                
                [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusError forMessage:attachmentMessage];
            }
            else {
                
                [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:attachmentMessage];
            }
            
            if (completion) {
                completion(response.error.error, nil);
            }
            
        }];
    }
    else {
        // attachment ID is UID
        __weak __typeof(self)weakSelf = self;
        [QBRequest downloadFileWithUID:attachment.ID successBlock:^(QBResponse *response, NSData *fileData) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [strongSelf saveImageData:fileData chatAttachment:attachment error:&error];
            
            if (image != nil) {
                strongSelf.attachmentsStorage[attachment.ID] = image;
            }
            
            [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:attachmentMessage];
            
            if (completion) {
                completion(error, image);
            }
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [strongSelf.delegate chatAttachmentService:strongSelf didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if (response.status == QBResponseStatusCodeNotFound) {
                
                [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusError forMessage:attachmentMessage];
            }
            else {
                
                [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:attachmentMessage];
            }
            
            if (completion) {
                completion(response.error.error, nil);
            }
        }];
    }
}

- (void)getImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion {
    [self imageForAttachmentMessage:attachmentMessage completion:completion];
}

- (void)localImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion {
    
    if (attachmentMessage.attachmentStatus == QMMessageAttachmentStatusLoading || attachmentMessage.attachmentStatus == QMMessageAttachmentStatusError) {
        return;
    }
    
    QBChatAttachment *attachment = [attachmentMessage.attachments firstObject];
    
    // checking attachment in storage
    if (self.attachmentsStorage[attachment.ID] != nil) {
        if (completion) {
            completion(nil, self.attachmentsStorage[attachment.ID]);
        }
        return;
    }
    
    // checking attachment in cache
    NSString *path = attachmentPath(attachment);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            
            if (image != nil) {
                self.attachmentsStorage[attachment.ID] = image;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error, image);
                }
            });
        });
        
        return;
    }
    
}

- (BOOL)saveImageData:(NSData *)imageData chatAttachment:(QBChatAttachment *)attachment error:(NSError **)errorPtr {
    
    NSString *path = attachmentPath(attachment);
    
    return [imageData writeToFile:path options:NSDataWritingAtomic error:errorPtr];
}

- (void)changeMessageAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message {
    
    message.attachmentStatus = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeAttachmentStatus:forMessage:)]) {
            [self.delegate chatAttachmentService:self didChangeAttachmentStatus:status forMessage:message];
        }
        
    });
}

@end
