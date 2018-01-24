//
//  QMAssetLoader.m
//
//
//  Created by Vitaliy Gurkovsky on 2/26/17.
//
//

#import "QMAssetLoader.h"
#import "QMSLog.h"
#import "QMTimeOut.h"
#import "QMSLog.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

static inline NSArray *QMAssetKeysArrayForOptions(QMAssetLoaderKeyOptions options) {
    
    NSMutableArray *keys = [NSMutableArray array];
    
    if (options & QMAssetLoaderKeyTracks) {
        [keys addObject:@"tracks"];
    }
    if (options & QMAssetLoaderKeyDuration) {
        [keys addObject:@"duration"];
    }
    if (options & QMAssetLoaderKeyPlayable) {
        [keys addObject:@"playable"];
    }
    
    return keys.copy;
}

@interface QMAssetOperationResult : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) CGSize mediaSize;

@end

@implementation QMAssetOperationResult

@end

@interface QMAssetOperation()

@property (strong ,nonatomic) AVAsset *asset;
@property (strong, nonatomic) NSURL *assetURL;
@property (copy, nonatomic) NSString *messageID;
@property (assign, nonatomic) QMAttachmentType contentType;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong, nonatomic) QMTimeOut *preloadTimeout;
@property (copy, nonatomic) QMAssetLoaderCompletionBlock completion;
@property (assign, nonatomic) QMAssetLoaderKeyOptions assetKeyOptions;
@property (nonatomic, strong) dispatch_queue_t assetQueue;

@end

@implementation QMAssetOperation
@synthesize asset = _asset;

//MARK: - NSObject

- (instancetype)initWithID:(NSString *)operationID
                       URL:(NSURL *)assetURL
            attachmentType:(QMAttachmentType)type
                   timeOut:(NSTimeInterval)timeInterval
                   options:(QMAssetLoaderKeyOptions)options
           completionBlock:(QMAssetLoaderCompletionBlock)completion {
    
    if (self = [super init]) {
        
        _messageID = operationID;
        self.operationID = operationID;
        _assetURL = assetURL;
        _contentType = type;
        _completion = [completion copy];
        _assetKeyOptions = options;
        
        NSString *identifier = @"QMAssetOperation";
        
        _assetQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_assetQueue, (__bridge const void *)(_assetQueue),
                                    (__bridge void *)(self), NULL);
        
        if (timeInterval > 0) {
            _preloadTimeout = [[QMTimeOut alloc] initWithTimeInterval:timeInterval
                                                                queue:nil];
        }
    }
    
    return self;
}

//MARK: - AVAsset

- (AVAsset *)getAssetInternal {
    
    if (!_asset) {
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
        _asset = [[AVURLAsset alloc] initWithURL:_assetURL
                                         options:options];
    }
    return _asset;
}

// Public accessor always copies the asset since assets
// can only safely be accessed from one thread at a time.

- (AVAsset *)asset {
    
    __block AVAsset *theAsset = nil;
    
    dispatch_sync(self.assetQueue, ^(void) {
        theAsset = [[self getAssetInternal] copy];
    });
    
    return theAsset;
}


- (void)asynchronouslyLoadURLAsset {
    
    NSArray *requestedKeys = QMAssetKeysArrayForOptions(self.assetKeyOptions);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.assetQueue, ^(void) {
        
        AVAsset *asset = [self getAssetInternal];
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys
                             completionHandler:^{
                                 
                                 dispatch_async(self.assetQueue, ^(void) {
                                     
                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                     
                                     AVAsset *asset = [self getAssetInternal];
                                     
                                     for (NSString *key in requestedKeys) {
                                         
                                         NSError *error = nil;
                                         
                                         AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key
                                                                                           error:&error];
                                         if (keyStatus == AVKeyValueStatusFailed) {
                                             [strongSelf finishOperationWithResult:nil
                                                                             error:error];
                                             return;
                                         }
                                     }
                                     
                                     if (strongSelf.isCancelled) {
                                         return;
                                     }
                                     
                                     [strongSelf prepareAsset:asset];
                                 });
                             }];
    });
    
}

- (void)prepareAsset:(AVAsset *)asset {
    
    QMAssetOperationResult *result = [QMAssetOperationResult new];
    
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    
    result.duration = duration;
    
    CGSize mediaSize = CGSizeZero;
    
    if (self.contentType == QMAttachmentContentTypeVideo) {
        
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        
        if (videoTracks.count > 0) {
            
            AVAssetTrack *videoTrack = [videoTracks firstObject];
            CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
            CGFloat videoWidth = videoSize.width;
            CGFloat videoHeight = videoSize.height;
            
            mediaSize = CGSizeMake(videoWidth, videoHeight);
            result.mediaSize = mediaSize;
            
            
            CMTime thumbnailTime = CMTimeMake(duration > 0 ? duration/2 : 0,
                                              1);
            
            __weak typeof(self) weakSelf = self;
            
            [self generateThumbnailFromAsset:asset
                                    withSize:mediaSize
                               thumbnailTime:thumbnailTime
                           completionHandler:^(UIImage *thumbnail, NSError *error) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               
                               if (strongSelf.isCancelled) {
                                   return;
                               }
                               
                               if (error) {
                                   [strongSelf finishOperationWithResult:nil
                                                                   error:error];
                                   return;
                               }
                               
                               result.image = thumbnail;
                               
                               [strongSelf finishOperationWithResult:result
                                                               error:nil];
                               
                           }];
        }
        else {
            NSError *error =
            [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                code:0
                            userInfo:@{NSLocalizedDescriptionKey : @"There are no video tracks for video asset"}];
            [self finishOperationWithResult:nil
                                      error:error];
        }
    }
    else {
        [self finishOperationWithResult:result
                                  error:nil];
    }
}

- (void)generateThumbnailFromAsset:(AVAsset *)thumbnailAsset
                          withSize:(CGSize)size
                     thumbnailTime:(CMTime)thumbnailTime
                 completionHandler:(void (^)(UIImage *thumbnail, NSError *error))handler
{
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:thumbnailAsset];
    
    _imageGenerator.appliesPreferredTrackTransform = YES;
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        
        BOOL isVerticalVideo = size.width < size.height;
        
        size = isVerticalVideo ? CGSizeMake(142.0, 270.0) : CGSizeMake(270.0, 142.0);
    }
    
    _imageGenerator.maximumSize = size;
    
    NSValue *imageTimeValue = [NSValue valueWithCMTime:thumbnailTime];
    
    if (self.isCancelled) {
        return;
    }
    
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:@[imageTimeValue]
                                          completionHandler:
     ^(CMTime requestedTime,
       CGImageRef image,
       CMTime actualTime,
       AVAssetImageGeneratorResult result,
       NSError *error)
     {
         if (self.isCancelled) {
             return;
         }
         
         if (result == AVAssetImageGeneratorFailed ||
             result == AVAssetImageGeneratorCancelled) {
             
             handler(nil, error);
         }
         else {
             
             UIImage *thumbUIImage = nil;
             if (image) {
                 thumbUIImage = [[UIImage alloc] initWithCGImage:image];
             }
             
             if (handler) {
                 handler(thumbUIImage, nil);
             }
         }
     }];
}


//MARK: - QMAsynchronousOperation

- (void)asyncTask {
    
    if (self.preloadTimeout) {
        __weak typeof(self) weakSelf = self;
        
        [self.preloadTimeout startWithFireBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                                 code:408
                                             userInfo:nil];
            [strongSelf finishOperationWithResult:nil
                                            error:error];
        }];
    }
    
    [self asynchronouslyLoadURLAsset];
}

- (void)finishOperationWithResult:(QMAssetOperationResult *)result
                            error:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_completion) {
            _completion(result.duration,
                        result.mediaSize,
                        result.image,
                        error);
        }
        
        [_preloadTimeout cancelTimeout];
        _completion = nil;
        
    });
    
    [self finish];
}

- (void)cancel {
    
    [self.preloadTimeout cancelTimeout];
    
    dispatch_async(self.assetQueue, ^(void) {
        [[self getAssetInternal] cancelLoading];
        [self.imageGenerator cancelAllCGImageGeneration];
    });
    
    [super cancel];
}

@end
