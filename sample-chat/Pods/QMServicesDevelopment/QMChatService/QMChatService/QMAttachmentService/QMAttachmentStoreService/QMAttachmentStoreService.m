//
//  QMMediaStoreService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMAttachmentStoreService.h"
#import "QMSLog.h"

#import "QBChatAttachment+QMCustomParameters.h"

@interface QMAttachmentStoreService() {
    NSFileManager *_fileManager;
}

@property (nonatomic, strong) NSMutableDictionary *imagesMemoryStorage;
@property (nonatomic, readwrite) QMAttachmentsMemoryStorage *attachmentsMemoryStorage;
@property (nonatomic, strong, nullable) dispatch_queue_t storeServiceQueue;
@property (strong, nonatomic, nonnull) NSString *diskMediaCachePath;

@end

@implementation QMAttachmentStoreService

//MARK: - NSObject

- (instancetype)initWithDelegate:(id<QMAttachmentStoreServiceDelegate>)delegate {
    
    self = [super init];
    
    if (self) {
        _jpegCompressionQuality = 1.0;
        _storeDelegate = delegate;
        _imagesMemoryStorage = [NSMutableDictionary dictionary];
        _attachmentsMemoryStorage = [[QMAttachmentsMemoryStorage alloc] init];
        _storeServiceQueue = dispatch_queue_create("QMStoreServiceQueue", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApplicationMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        _diskMediaCachePath = mediaCacheDir();
        dispatch_sync(_storeServiceQueue, ^{
            _fileManager = [NSFileManager new];
        });
    }
    
    return self;
}

- (void)dealloc {
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}


//MARK: - QMMediaStoreServiceDelegate

- (void)attachmentWithID:(NSString *)attachmentID
               messageID:(NSString *)messageID
                dialogID:(NSString *)dialogID {
    
    if (attachmentID != nil) {
        [_attachmentsMemoryStorage attachmentWithID:attachmentID fromMessageID:messageID];
    }
}

- (void)cachedDataForAttachment:(QBChatAttachment *)attachment
                      messageID:(NSString *)messageID
                       dialogID:(NSString *)dialogID
                     completion:(nonnull void (^)(NSURL * _Nullable, NSData * _Nullable))completion {
    
    dispatch_async(_storeServiceQueue, ^{
        
        NSString *path = mediaPath(dialogID, messageID, attachment);
        NSData *data = nil;
        
        if ([_fileManager fileExistsAtPath:path]) {
            
            NSError *error;
            data = [NSData dataWithContentsOfFile:path
                                          options:NSDataReadingMappedIfSafe
                                            error:&error];
            if (error) {
                QMSLog(@"ERROR: %@ - %@, error:%@",  NSStringFromSelector(_cmd), self, error);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                NSURL *fileURL = data ? [NSURL fileURLWithPath:path] : nil;
                completion(fileURL, data);
            }
        });
    });
}

- (void)cachedImageForAttachment:(QBChatAttachment *)attachment
                       messageID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                      completion:(void (^)(UIImage *))completion {
    
    if (self.imagesMemoryStorage[messageID] != nil) {
        
        if (completion) {
            completion(self.imagesMemoryStorage[messageID]);
        }
        return;
    }
    
    [self cachedDataForAttachment:attachment
                        messageID:messageID
                         dialogID:dialogID
                       completion:^(NSURL * _Nullable fileURL, NSData * _Nullable data)
     {
         UIImage *image = nil;
         if (data) {
             UIImage *image = [UIImage imageWithData:data];
             self.imagesMemoryStorage[messageID] = image;
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(image);
         });
     }];
    
}

- (QBChatAttachment *)cachedAttachmentWithID:(NSString *)attachmentID
                                forMessageID:(NSString *)messageID {
    
    return [self.attachmentsMemoryStorage attachmentWithID:attachmentID
                                             fromMessageID:messageID];
}

- (NSData *)dataForImage:(UIImage*)image {
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    if (hasAlpha) {
        return UIImagePNGRepresentation(image);
    }
    else {
        return UIImageJPEGRepresentation(image, self.jpegCompressionQuality);
    }
}

- (void)storeAttachment:(QBChatAttachment *)attachment
              withData:(nullable NSData *)data
             cacheType:(QMAttachmentCacheType)cacheType
             messageID:(NSString *)messageID
              dialogID:(NSString *)dialogID
            completion:(dispatch_block_t)completion {
    
    NSAssert(attachment.ID, @"No ID");
    NSAssert(messageID, @"No ID");
    NSAssert(dialogID, @"No ID");
    
    if (!data) {
        if (attachment.image) {
            self.imagesMemoryStorage[messageID] = attachment.image;
            data = [self dataForImage:attachment.image];
        }
        else if (attachment.localFileURL) {
            data = [NSData dataWithContentsOfURL:attachment.localFileURL];
        }
    }
    
    if (data) {
        [self saveData:data
         forAttachment:attachment
             cacheType:cacheType
             messageID:messageID
              dialogID:dialogID
            completion:completion];
    }
    else {
        if (completion) {
            completion();
        }
    }
}

- (void)saveData:(NSData *)data
   forAttachment:(QBChatAttachment *)attachment
       cacheType:(QMAttachmentCacheType)cacheType
       messageID:(NSString *)messageID
        dialogID:(NSString *)dialogID
      completion:(dispatch_block_t)completion {
    
    NSAssert(attachment.ID, @"No ID");
    NSAssert(messageID, @"No ID");
    NSAssert(dialogID, @"No ID");
    NSAssert(data.length, @"No data");
    
    dispatch_block_t saveToCacheBlock = ^{
        
        if (cacheType & QMAttachmentCacheTypeMemory) {
            
            [self.attachmentsMemoryStorage addAttachment:attachment
                                            forMessageID:messageID];
            
            [self updateAttachment:attachment
                         messageID:messageID
                          dialogID:dialogID];
            
        }
    };
    
    if (cacheType & QMAttachmentCacheTypeDisc) {
        
        dispatch_async(self.storeServiceQueue, ^{
            
            NSString *pathToFile = mediaPath(dialogID,
                                             messageID,
                                             attachment);
            
            if (![_fileManager fileExistsAtPath:[pathToFile stringByDeletingLastPathComponent]]) {
                [_fileManager createDirectoryAtPath:[pathToFile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            QMSLog(@"CREATE FILE AT PATH %@", pathToFile);
            
            if  (![_fileManager createFileAtPath:pathToFile contents:data attributes:nil]) {
                QMSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
            }
            
            attachment.localFileURL = [NSURL fileURLWithPath:pathToFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                saveToCacheBlock();
                if (completion) {
                    completion();
                }
            });
        });
    }
    else {
        saveToCacheBlock();
        if (completion) {
            completion();
        }
    }
}



//MARK: - Removing

- (void)clearCacheForType:(QMAttachmentCacheType)cacheType
               completion:(dispatch_block_t)completion {
    
    dispatch_block_t clearMemoryBlock = ^{
        
        if (cacheType & QMAttachmentCacheTypeMemory) {
            [self.attachmentsMemoryStorage free];
            [self.imagesMemoryStorage removeAllObjects];
        }
    };
    
    if (cacheType & QMAttachmentCacheTypeDisc) {
        
        dispatch_async(self.storeServiceQueue, ^{
            
            [_fileManager removeItemAtPath:self.diskMediaCachePath error:nil];
            [_fileManager createDirectoryAtPath:self.diskMediaCachePath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                clearMemoryBlock();
                if (completion) {
                    completion();
                }
            });
        });
    }
    else {
        clearMemoryBlock();
        if (completion) {
            completion();
        }
    }
}

- (void)clearCacheForDialogWithID:(NSString *)dialogID
                        cacheType:(QMAttachmentCacheType)cacheType
                       completion:(nullable dispatch_block_t)completion {
    
    dispatch_async(self.storeServiceQueue, ^{
        
        NSString *dialogPath = [_diskMediaCachePath stringByAppendingPathComponent:dialogID];
        [_fileManager removeItemAtPath:dialogPath
                                 error:nil];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)clearCacheForMessagesWithIDs:(NSArray <NSString *> *)messagesIDs
                            dialogID:(NSString *)dialogID
                           cacheType:(QMAttachmentCacheType)cacheType
                          completion:(nullable dispatch_block_t)completion {
    
    dispatch_async(self.storeServiceQueue, ^{
        
        NSString *dialogPath = [_diskMediaCachePath stringByAppendingPathComponent:dialogID];
        
        for (NSString *messageID in messagesIDs) {
            
            NSString *messagePath = [dialogPath stringByAppendingPathComponent:messageID];
            [_fileManager removeItemAtPath:messagePath
                                     error:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)clearCacheForMessageWithID:(NSString *)messageID
                          dialogID:(NSString *)dialogID
                         cacheType:(QMAttachmentCacheType)cacheType
                        completion:(nullable dispatch_block_t)completion {
    
    [self clearCacheForMessagesWithIDs:@[messageID]
                              dialogID:dialogID
                             cacheType:cacheType
                            completion:completion];
}



//MARK: - Helpers
- (NSURL *)fileURLForAttachment:(QBChatAttachment *)attachment
                      messageID:(NSString *)messageID
                       dialogID:(NSString *)dialogID {
    
    __block NSURL *fileURL = nil;
    dispatch_sync(self.storeServiceQueue, ^{
        NSString *path = mediaPath(dialogID, messageID, attachment);
        if ([_fileManager fileExistsAtPath:path]) {
            fileURL = [NSURL fileURLWithPath:path];
        }
    });
    return fileURL;
}

- (NSUInteger)sizeForMessageWithID:(nullable NSString *)messageID
                          dialogID:(NSString *)dialogID {
    
    NSString *path = [_diskMediaCachePath stringByAppendingPathComponent:dialogID];
    if (messageID != nil) {
        path = [path stringByAppendingPathComponent:messageID];
    }
    return [self sizeForPath:path];
}


- (void)updateAttachment:(nonnull QBChatAttachment *)attachment
               messageID:(nonnull NSString *)messageID
                dialogID:(nonnull NSString *)dialogID {
    
    [self.attachmentsMemoryStorage updateAttachment:attachment forMessageID:messageID];
    
    if ([self.storeDelegate respondsToSelector:@selector(storeService:
                                                         didUpdateAttachment:
                                                         messageID:
                                                         dialogID:)]) {
        [self.storeDelegate storeService:self
                     didUpdateAttachment:attachment
                               messageID:messageID
                                dialogID:dialogID];
    }
}

//MARK: - Helpers

- (NSString *)mimeTypeForData:(NSData *)data {
    
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

//MARK: - Notifications

- (void)didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification {
    
    [self.imagesMemoryStorage removeAllObjects];
    [self.attachmentsMemoryStorage free];
}

//MARK: - QMCancellableService

- (void)cancelOperationWithID:(NSString *)operationID {
    
}

- (void)cancelAllOperations {
    
}

- (NSUInteger)sizeForPath:(NSString *)path {
    __block NSUInteger size = 0;
    dispatch_sync(self.storeServiceQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskMediaCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskMediaCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

//MARK: - Static methods.

static NSString* mediaCacheDir() {
    
    static NSString *mediaCacheDirString;
    
    if (!mediaCacheDirString) {
        
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        mediaCacheDirString = [cacheDir stringByAppendingPathComponent:@"Attachments"];
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            if (![[NSFileManager defaultManager] fileExistsAtPath:mediaCacheDirString]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:mediaCacheDirString withIntermediateDirectories:NO attributes:nil error:nil];
            }
        });
    }
    
    return mediaCacheDirString;
}


static NSString* mediaPath(NSString *dialogID, NSString *messsageID, QBChatAttachment *attachment)   {
    
    NSString *mediaPatch =
    [[mediaCacheDir() stringByAppendingPathComponent:dialogID]
     stringByAppendingPathComponent:messsageID];
    
    NSString *filePath =
    [NSString stringWithFormat:@"/attachment-%@.%@",
     messsageID,
     attachment.fileExtension];
    
    return [mediaPatch stringByAppendingPathComponent:filePath];
}

@end
