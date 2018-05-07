//
//  QMImageLoader.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 9/12/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import "QMImageLoader.h"
#import <Quickblox/Quickblox.h>

@interface QMWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (copy, nonatomic) NSString *operationID;
@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;
@property (strong, nonatomic) NSOperation *cacheOperation;

@end

@interface QMImageTransform()

@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) QMImageTransformType transformType;
@property (assign, nonatomic) BOOL isCircle; //deprecate
@property (copy, nonatomic, nullable) QMCustomTransformBlock customTransformBlock;

@property (copy, nonatomic) NSString *spec;

@end

@implementation QMImageTransform

+ (instancetype)transformWithType:(QMImageTransformType)transformType
                             size:(CGSize)size {
    QMImageTransform *transform = [[QMImageTransform alloc] init];
    transform.size = size;
    transform.transformType = transformType;
    
    return transform;
}

+ (instancetype)transformWithSize:(CGSize)size customTransformBlock:(QMCustomTransformBlock)customTransformBlock {
    
    QMImageTransform *transform = [[QMImageTransform alloc] init];
    transform.size = size;
    transform.transformType = QMImageTransformTypeCustom;
    transform.customTransformBlock = customTransformBlock;
    
    return transform;
}

+ (instancetype)transformWithSize:(CGSize)size isCircle:(BOOL)isCircle {
    
    QMImageTransformType transformType = isCircle ? QMImageTransformTypeCircle : QMImageTransformTypeScaleAndCrop;
    
    return  [QMImageTransform transformWithType:transformType size:size];
}

- (NSString *)keyWithURL:(NSURL *)url {
    
    return [NSString stringWithFormat:@"%@_%@_%@",
            stringWithImageTransformType(_transformType),
            NSStringFromCGSize(_size), url.absoluteString];
}

- (void)applyTransformForImage:(UIImage *)image completionBlock:(void(^)(UIImage *transformedImage))transformCompletionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        UIImage *transformed = [self imageManager:nil transformDownloadedImage:image withURL:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            transformCompletionBlock(transformed);
        });
    });
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager
 transformDownloadedImage:(UIImage *)image
                  withURL:(NSURL *)imageURL {
    
    switch (_transformType) {
            
        case QMImageTransformTypeScaleAndCrop: {
            
            return [image imageByScaleAndCrop:self.size];
            break;
        }
        case QMImageTransformTypeCircle: {
            
            return [image imageByCircularScaleAndCrop:self.size];
            break;
            
        }
        case QMImageTransformTypeCustom: {
            
            if (self.customTransformBlock) {
                UIImage *transformedImage = self.customTransformBlock(imageURL, image);
                return transformedImage;
            }
            else {
                NSAssert(NO, @"self.customTransformBlock == nil");
            }
            
            break;
        }
        case QMImageTransformTypeRounding: {
            
            return [image imageWithCornerRadius:4 targetSize:self.size];
            break;
        }
            
        default:
        {
            NSAssert(NO, @"Undefined image transform type");
            break;
        }
    }
    return nil;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@ size:%@ transformType:%@",
            [super description],
            NSStringFromCGSize(self.size),
            stringWithImageTransformType(_transformType)];
}

NSString *stringWithImageTransformType(QMImageTransformType transformType) {
    NSArray *arr = @[
                     @"QMImageTransformTypeScaleAndCrop",
                     @"QMImageTransformTypeCircle",
                     @"QMImageTransformTypeRounding",
                     @"QMImageTransformTypeCustom"
                     ];
    return (NSString *)[arr objectAtIndex:transformType];
}


@end

@interface QMImageLoader()

@property (strong, nonatomic) NSMutableSet *failedURLs;
@property (strong, nonatomic) NSMutableDictionary *runningOperations;

@end

@implementation QMImageLoader

- (void)cancelAll {
    
    @synchronized (self.runningOperations) {
        
        NSArray<QMWebImageCombinedOperation *> *copiedOperations = [self.runningOperations.allValues copy];
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeAllObjects];
    }
}

- (void)cancelImageOperationForURL:(NSURL *)url {
    
    NSString *operationID = [self cacheKeyForURL:url];
    
    QMWebImageCombinedOperation *operation = self.runningOperations[operationID];
    [operation cancel];
    
    @synchronized (self.runningOperations) {
        [self.runningOperations removeObjectForKey:operationID];
    }
}

+ (instancetype)instance {
    
    static dispatch_once_t onceToken;
    static QMImageLoader *_loader = nil;
    dispatch_once(&onceToken, ^{
        
        SDImageCache *qmCache = nil;
        NSString *groupIdentifier = QBSettings.applicationGroupIdentifier;
        if (groupIdentifier.length > 0) {
            
            NSString *diskCacheDirectory = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier].path stringByAppendingPathComponent:@"default"];
            
            qmCache = diskCacheDirectory.length ?
            [[SDImageCache alloc] initWithNamespace:@"default"
                                 diskCacheDirectory:diskCacheDirectory] :
            [[SDImageCache alloc] initWithNamespace:@"default"];
        }
        else {
            qmCache = [[SDImageCache alloc] initWithNamespace:@"default"];
        }
        
        qmCache.maxMemoryCost = 15 * 1024 * 1024;
        
        SDWebImageDownloader *qmDownloader = [SDWebImageDownloader sharedDownloader];
        
        _loader = [[QMImageLoader alloc] initWithCache:qmCache downloader:qmDownloader];
    });
    
    return _loader;
}

- (instancetype)initWithCache:(SDImageCache *)cache
                   downloader:(SDWebImageDownloader *)downloader {
    
    self = [super initWithCache:cache downloader:downloader];
    if (self) {
        _runningOperations = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)safelyRemoveOperationFromRunning:(nullable QMWebImageCombinedOperation *)operation {
    
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObjectForKey:operation.operationID];
        }
    }
}
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                       transform:(QMImageTransform *)transform
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(QMWebImageCompletionWithFinishedBlock)completedBlock {
    
    return [self downloadImageWithURL:url
                                token:nil
                            transform:transform
                              options:options
                             progress:progressBlock
                            completed:completedBlock];
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                           token:(NSString *)token
                                       transform:(QMImageTransform *)transform
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(QMWebImageCompletionWithFinishedBlock)completedBlock {
    
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");
    
    __weak __typeof(self)weakSelf = self;
    
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    
    QMWebImageCombinedOperation *operation = [QMWebImageCombinedOperation new];
    __weak QMWebImageCombinedOperation *weakOperation = operation;
    
    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }
    
    if (url.absoluteString.length == 0 ||
        (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
        });
        
        return operation;
    }
    
    NSString *operationID = [self cacheKeyForURL:url];
    operation.operationID = operationID;
    @synchronized (self.runningOperations) {
        self.runningOperations[operationID] = operation;
    }
    
    NSString *key = [self cacheKeyForURL:url];
    NSString *transformKey = [transform keyWithURL:url];
    
    typedef NSOperation *(^qm_cache_operation)(void);
    
    qm_cache_operation cacheOp = ^() {
        
        return [weakSelf.imageCache queryCacheOperationForKey:key done:^(UIImage * _Nullable image,
                                                                         NSData * _Nullable data,
                                                                         SDImageCacheType cacheType) {
            
            if (weakOperation.isCancelled) {
                [weakSelf safelyRemoveOperationFromRunning:weakOperation];
                
                return;
            }
            
            if ((!image || options & SDWebImageRefreshCached) &&
                (![weakSelf.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] ||
                 [weakSelf.delegate imageManager:weakSelf shouldDownloadImageForURL:url])) {
                    
                    if (image && options & SDWebImageRefreshCached) {
                        dispatch_main_async_safe(^{
                            // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                            completedBlock(image, nil, nil, cacheType, YES, url);
                        });
                    }
                    
                    // download if no image or requested to refresh anyway, and download allowed by delegate
                    SDWebImageDownloaderOptions downloaderOptions = 0;
                    if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
                    if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
                    if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
                    if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
                    if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
                    if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
                    if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
                    if (image && options & SDWebImageRefreshCached) {
                        // force progressive off if image already cached but forced refreshing
                        downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                        // ignore image read from NSURLCache if image if cached but force refreshing
                        downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
                    }
                    
                    NSURL *urlToDownload = url;
                    
                    if (token) {
                        NSURLComponents *components =
                        [NSURLComponents componentsWithURL:url
                                   resolvingAgainstBaseURL:false];
                        
                        components.query = [NSString stringWithFormat:@"token=%@",token];
                        
                        urlToDownload = [components URL];
                    }
                    
                    SDWebImageDownloadToken * subOperation =
                    [weakSelf.imageDownloader downloadImageWithURL:urlToDownload
                                                           options:downloaderOptions
                                                          progress:progressBlock
                                                         completed:^(UIImage *downloadedImage,
                                                                     NSData *data,
                                                                     NSError *error,
                                                                     BOOL finished)
                     {
                         __strong __typeof(weakOperation) strongOperation = weakOperation;
                         if (!strongOperation || strongOperation.isCancelled) {
                             // Do nothing if the operation was cancelled
                             // See #699 for more details
                             // if we would call the completedBlock, there could be a race condition
                             // between this block and another completedBlock for the same object, so
                             // if this one is called second, we will overwrite the new data
                         }
                         else if (error) {
                             
                             dispatch_main_async_safe(^{
                                 
                                 if (strongOperation && !strongOperation.isCancelled) {
                                     completedBlock(nil, nil, error, SDImageCacheTypeNone, finished, url);
                                 }
                             });
                             
                             if (error.code != NSURLErrorNotConnectedToInternet &&
                                 error.code != NSURLErrorCancelled &&
                                 error.code != NSURLErrorTimedOut &&
                                 error.code != NSURLErrorInternationalRoamingOff &&
                                 error.code != NSURLErrorDataNotAllowed &&
                                 error.code != NSURLErrorCannotFindHost &&
                                 error.code != NSURLErrorCannotConnectToHost) {
                                 @synchronized (weakSelf.failedURLs) {
                                     [weakSelf.failedURLs addObject:url];
                                 }
                             }
                         }
                         else {
                             
                             if ((options & SDWebImageRetryFailed)) {
                                 @synchronized (weakSelf.failedURLs) {
                                     [weakSelf.failedURLs removeObject:url];
                                 }
                             }
                             
                             BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                             
                             if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                                 // Image refresh hit the NSURLCache cache, do not call the completion block
                             }
                             else if (downloadedImage &&
                                      (!downloadedImage.images ||
                                       (options & SDWebImageTransformAnimatedImage)) && transform)
                             {
                                 
                                 
                                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                     
                                     UIImage *transformedImage =
                                     [weakSelf imageManager:weakSelf
                                                  transform:transform
                                   transformDownloadedImage:downloadedImage
                                                    withURL:url];
                                     
                                     if (transformedImage && finished) {
                                         
                                         BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                         
                                         [weakSelf.imageCache storeImage:downloadedImage
                                                               imageData:(imageWasTransformed ? nil : data)
                                                                  forKey:key
                                                                  toDisk:cacheOnDisk
                                                              completion:nil];
                                     }
                                     
                                     
                                     dispatch_main_async_safe(^{
                                         
                                         if (strongOperation && !strongOperation.isCancelled) {
                                             
                                             completedBlock(downloadedImage,
                                                            transformedImage,
                                                            nil,
                                                            SDImageCacheTypeNone,
                                                            finished,
                                                            url);
                                         }
                                     });
                                 });
                             }
                             else {
                                 
                                 if (downloadedImage && finished) {
                                     
                                     [weakSelf.imageCache storeImage:downloadedImage
                                                           imageData:data
                                                              forKey:key toDisk:cacheOnDisk
                                                          completion:nil];
                                 }
                                 
                                 
                                 dispatch_main_async_safe(^{
                                     
                                     if (strongOperation && !strongOperation.isCancelled) {
                                         completedBlock(downloadedImage,
                                                        nil,
                                                        nil,
                                                        SDImageCacheTypeNone, finished, url);
                                     }
                                 });
                             }
                         }
                         
                         if (finished) {
                             
                             [weakSelf safelyRemoveOperationFromRunning:operation];
                         }
                     }];
                    
                    @synchronized (operation){
                        
                        __weak __typeof(subOperation)weakSuboperation = subOperation;
                        weakOperation.cancelBlock = ^{
                            
                            [weakSelf.imageDownloader cancel:weakSuboperation];
                            __strong __typeof(weakOperation) strongOperation = weakOperation;
                            [weakSelf safelyRemoveOperationFromRunning:strongOperation];
                        };
                    }
                }
            else if (image) {
                
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                
                if (transform) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        
                        UIImage *transformedImage = [weakSelf.imageCache imageFromDiskCacheForKey:transformKey];
                        
                        if (!transformedImage) {
                            
                            transformedImage =
                            [weakSelf imageManager:weakSelf
                                         transform:transform
                          transformDownloadedImage:image
                                           withURL:url];
                            
                            
                            dispatch_main_async_safe(^{
                                
                                if (strongOperation && !strongOperation.isCancelled) {
                                    completedBlock(image, transformedImage, nil, cacheType, YES, url);
                                }
                            });
                            @synchronized (weakSelf.runningOperations) {
                                [weakSelf.runningOperations removeObjectForKey:operationID];
                            }
                        }
                        else {
                            
                            dispatch_main_async_safe(^{
                                
                                if (strongOperation && !strongOperation.isCancelled) {
                                    completedBlock(image, transformedImage, nil, cacheType, YES, url);
                                }
                            });
                            @synchronized (weakSelf.runningOperations) {
                                [weakSelf.runningOperations removeObjectForKey:operationID];
                            }
                        }
                    });
                    
                } else {
                    
                    dispatch_main_async_safe(^{
                        
                        if (strongOperation && !strongOperation.isCancelled) {
                            completedBlock(image, nil, nil, cacheType, YES, url);
                        }
                    });
                    [weakSelf safelyRemoveOperationFromRunning:weakOperation];
                }
            }
            else {
                // Image not in cache and download disallowed by delegate
                
                dispatch_main_async_safe(^{
                    __strong __typeof(weakOperation) strongOperation = weakOperation;
                    if (strongOperation && !weakOperation.isCancelled) {
                        completedBlock(nil, nil, nil, SDImageCacheTypeNone, YES, url);
                    }
                });
                [weakSelf safelyRemoveOperationFromRunning:weakOperation];
            }
        }];
    };
    
    if (transform) {
        
        [self.imageCache queryCacheOperationForKey:transformKey
                                              done:^(UIImage * _Nullable tranformedImageFromCache,
                                                     NSData * _Nullable data,
                                                     SDImageCacheType cacheType)
         {
             if (tranformedImageFromCache) {
                 
                 __strong __typeof(weakOperation) strongOperation = weakOperation;
                 
                 dispatch_main_async_safe(^{
                     if (strongOperation && !strongOperation.isCancelled) {
                         completedBlock(nil, tranformedImageFromCache, nil, cacheType, YES, url);
                     }
                 });
                 
                 [weakSelf safelyRemoveOperationFromRunning:weakOperation];
                 return;
             }
             
             weakOperation.cacheOperation = cacheOp();
         }];
    }
    else {
        
        operation.cacheOperation = cacheOp();
    }
    
    return operation;
}

- (UIImage *)originalImageWithURL:(NSURL *)url {
    
    return [self.imageCache imageFromDiskCacheForKey:url.absoluteString];
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager
                transform:(QMImageTransform *)transform
 transformDownloadedImage:(UIImage *)image
                  withURL:(NSURL *)imageURL {
    
    if (transform) {
        
        NSString *transformKey = [transform keyWithURL:imageURL];
        UIImage *transformedImage = [transform imageManager:imageManager
                                   transformDownloadedImage:image
                                                    withURL:imageURL];
        [self.imageCache storeImage:transformedImage
                          imageData:nil
                             forKey:transformKey
                             toDisk:YES
                         completion:nil];
        
        return transformedImage;
    }
    
    return nil;
}

- (void)cancelOperationWithURL:(NSURL *)url {
    
    [[self operationWithURL:url] cancel];
}

- (QMWebImageCombinedOperation *)operationWithURL:(NSURL *)url {
    
    NSString *key = [self cacheKeyForURL:url];
    
    QMWebImageCombinedOperation *operation = nil;
    @synchronized (self.runningOperations) {
        operation = self.runningOperations [key];
    }
    return operation;
}

- (BOOL)hasImageOperationWithURL:(NSURL *)url {
    
    return [self operationWithURL:url] != nil;
}

- (BOOL)hasOriginalImageWithURL:(NSURL *)url {
    
    BOOL exists = NO;
    
    NSString *key = [self cacheKeyForURL:url];
    NSString *path = [self.imageCache defaultCachePathForKey:key];
    if (path) {
        exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    }
    
    return exists;
}

- (NSString *)pathForOriginalImageWithURL:(NSURL *)url {
    
    NSString *key = [self cacheKeyForURL:url];
    NSString *path = [self.imageCache defaultCachePathForKey:key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    
    return nil;
}

@end

@implementation QMWebImageCombinedOperation

- (void)dealloc {
    
}

- (void)setCancelBlock:(SDWebImageNoParamsBlock)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil; // don't forget to nil the cancelBlock, otherwise we will get crashes
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    
    self.cancelled = YES;
    
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
        //        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}

@end

