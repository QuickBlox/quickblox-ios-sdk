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
#import "QMChatService+AttachmentService.h"

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

- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    
    [chatService.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
    
    [self uploadAndSendAttachmentMessage:message toDialog:dialog withChatService:chatService withAttachedImage:image completion:completion];
}

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedImage:(UIImage *)image completion:(QBChatCompletionBlock)completion {
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading forMessage:message];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [QBRequest TUploadFile:imageData fileName:@"attachment" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
        
        QBChatAttachment *attachment = [QBChatAttachment new];
        attachment.type = @"image";
        attachment.ID = blob.UID;
        attachment.url = [blob privateUrl];
        
        message.attachments = @[attachment];
        message.text = @"Attachment image";
        
        [self saveImageData:imageData chatAttachment:attachment error:nil];
        [self.attachmentsStorage setObject:image forKey:attachment.ID];
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:message];
        
        [chatService sendMessage:message type:QMMessageTypeText toDialog:dialog saveToHistory:YES saveToStorage:YES completion:completion];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {

        if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeUploadingProgress:forMessage:)]) {
            [self.delegate chatAttachmentService:self didChangeUploadingProgress:status.percentOfCompletion forMessage:message];
        }
        
    } errorBlock:^(QBResponse *response) {
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:message];
        
        if (completion) completion(response.error.error);
    }];
}

- (void)getImageForChatAttachment:(QBChatAttachment *)attachment completion:(void (^)(NSError *error, UIImage *image))completion {
    
    NSString *path = attachmentPath(attachment);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error, image);
            });
        });

        return;
    }
    
    NSString *attachmentID = attachment.ID;
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([attachmentID rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        [QBRequest downloadFileWithID:attachmentID.integerValue successBlock:^(QBResponse *response, NSData *fileData) {
            
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [self saveImageData:fileData chatAttachment:attachment error:&error];
            
            if (completion) completion(error, image);
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [self.delegate chatAttachmentService:self didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            if (completion) completion(response.error.error, nil);
            
        }];
    }
    else {
        // Support for attachments that were send with old chat attachment service
        // old chat attachment service used UID for attachments instead of blobID
        [QBRequest downloadFileWithUID:attachment.ID successBlock:^(QBResponse *response, NSData *fileData) {
            
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [self saveImageData:fileData chatAttachment:attachment error:&error];
            
            if (completion) completion(error, image);

        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [self.delegate chatAttachmentService:self didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            if (completion) completion(response.error.error, nil);
            
        }];
    }
}

- (void)getImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion {
    
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
        [QBRequest downloadFileWithID:attachmentID.integerValue successBlock:^(QBResponse *response, NSData *fileData) {
            
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [self saveImageData:fileData chatAttachment:attachment error:&error];
            
            if (image != nil) {
                [self.attachmentsStorage setObject:image forKey:attachmentID];
            }
            
            [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:attachmentMessage];
            
            if (completion) completion(error, image);
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [self.delegate chatAttachmentService:self didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            if (response.status == QBResponseStatusCodeNotFound) {
                
                [self changeMessageAttachmentStatus:QMMessageAttachmentStatusError forMessage:attachmentMessage];
            } else {
                
                [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:attachmentMessage];
            }
            
            if (completion) completion(response.error.error, nil);
            
        }];
    }
    else {
        // attachment ID is UID
        [QBRequest downloadFileWithUID:attachment.ID successBlock:^(QBResponse *response, NSData *fileData) {
            
            UIImage *image = [UIImage imageWithData:fileData];
            NSError *error;
            
            [self saveImageData:fileData chatAttachment:attachment error:&error];
            if (image != nil) {
                [self.attachmentsStorage setObject:image forKey:attachmentID];
            }
            
            [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:attachmentMessage];
            
            if (completion) completion(error, image);
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            
            if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
                [self.delegate chatAttachmentService:self didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
            }
            
        } errorBlock:^(QBResponse *response) {
            
            if (response.status == QBResponseStatusCodeNotFound) {
                
                [self changeMessageAttachmentStatus:QMMessageAttachmentStatusError forMessage:attachmentMessage];
            } else {
                
                [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:attachmentMessage];
            }
            
            if (completion) completion(response.error.error, nil);
            
        }];
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
