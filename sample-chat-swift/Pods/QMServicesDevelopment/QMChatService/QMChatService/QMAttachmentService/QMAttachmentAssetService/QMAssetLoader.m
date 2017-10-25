//
//  QMAssetLoader.m
//
//
//  Created by Vitaliy Gurkovsky on 2/26/17.
//
//

#import "QMAssetLoader.h"
#import "QMSLog.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QMTimeOut.h"
#import "QMSLog.h"

@interface QMAssetLoader ()

@property (strong ,nonatomic) AVAsset *asset;
@property (strong, nonatomic) NSURL *assetURL;
@property (copy, nonatomic) NSString *messageID;
@property (assign, nonatomic) QMAttachmentType contentType;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong, nonatomic) QMTimeOut *preloadTimeout;
@property (copy, nonatomic) QMAssetLoaderCompletionBlock completion;
@property (assign, nonatomic, readwrite) QMAssetLoaderStatus loaderStatus;

@end

@implementation QMAssetLoader

//MARK - NSObject
- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    _completion = nil;
}

- (AVAsset *)asset {
    
    if (_asset == nil) {
        
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
        _asset = [[AVURLAsset alloc] initWithURL:_assetURL
                                         options:options];
    }
    
    return _asset;
}

+ (instancetype)loaderForAttachment:(QBChatAttachment *)attachment messageID:(NSString *)messageID {
    
    QMAssetLoader *assetLoader = [[QMAssetLoader alloc] init];
    NSURL *mediaURL = nil;
    
    if (attachment.localFileURL) {
        mediaURL = attachment.localFileURL;
    }
    else if (attachment.remoteURL) {
        mediaURL = attachment.remoteURL;
    }
    
    assetLoader.assetURL = mediaURL;
    assetLoader.loaderStatus = QMAssetLoaderStatusNotLoaded;
    assetLoader.contentType = attachment.attachmentType;
    assetLoader.messageID = messageID;
    
    return assetLoader;
}

- (void)loadWithTimeOut:(NSTimeInterval)timeOutInterval
        completionBlock:(QMAssetLoaderCompletionBlock)completionBlock {
    
    if (self.loaderStatus == QMAssetLoaderStatusNotLoaded && self.assetURL) {
        QMSLog(@"1 self.prepareStatus == QMMediaPrepareStatusNotPrepared %@", _messageID);
        self.completion = completionBlock;
        self.loaderStatus = QMAssetLoaderStatusLoading;
        
        __weak typeof(self) weakSelf = self;
        
        self.preloadTimeout = [[QMTimeOut alloc] initWithTimeInterval:timeOutInterval
                                                                queue:nil];
        [self.preloadTimeout startWithFireBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf cancel];
            NSError *error = [NSError errorWithDomain:@"QMerror" code:0 userInfo:nil];
            completionBlock(0, CGSizeZero, nil, error);
        }];
        
        [self asynchronouslyLoadURLAsset];
    }
}

- (void)asynchronouslyLoadURLAsset {
    
    NSArray *requestedKeys = @[@"tracks", @"duration", @"playable"];
    QMSLog(@"2 loadValuesAsynchronouslyForKeys %@", _messageID);
    
    __weak typeof(self) weakSelf = self;
    
    [self.asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        AVAsset *asset = strongSelf.asset;
        QMSLog(@"3 Completed Load %@", _messageID);
        if (strongSelf.loaderStatus == QMAssetLoaderStatusCancelled) {
            strongSelf.completion(0, CGSizeZero, nil, nil);
            return;
        }
        
        for (NSString *key in requestedKeys) {
            NSError *error = nil;
            AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
            if (keyStatus == AVKeyValueStatusFailed) {
                if (strongSelf.completion) {
                    [strongSelf.preloadTimeout cancelTimeout];
                    strongSelf.loaderStatus = QMAssetLoaderStatusFailed;
                    strongSelf.completion(0, CGSizeZero, nil, error);
                }
                return;
            }
        }
        
        [strongSelf prepareAsset:asset];
    }];
    
}

- (void)generateThumbnailFromAsset:(AVAsset *)thumbnailAsset withSize:(CGSize)size
                 completionHandler:(void (^)(UIImage *thumbnail, NSError *error))handler
{
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:thumbnailAsset];
    
    _imageGenerator.appliesPreferredTrackTransform = YES;
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        
        BOOL isVerticalVideo = size.width < size.height;
        
        size = isVerticalVideo ? CGSizeMake(142.0, 270.0) : CGSizeMake(270.0, 142.0);
    }
    
    _imageGenerator.maximumSize = size;
    NSValue *imageTimeValue = [NSValue valueWithCMTime:CMTimeMake(0, 1)];
    
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:imageTimeValue] completionHandler:
     ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         if (result == AVAssetImageGeneratorFailed || result == AVAssetImageGeneratorCancelled) {
             QMSLog(@"7 image gemenaritonWithResult: %@ %@",@"Failed or AVAssetImageGeneratorCancelled", _messageID);
             
             handler(nil, error);
         }
         else {
             QMSLog(@"7 image gemenaritonWithResult: %@ %@",@"Sucess", _messageID);
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

- (void)prepareAsset:(AVAsset *)asset {
    
    QMSLog(@"4 prepareAsset %@", _messageID);
    
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    CGSize mediaSize = CGSizeZero;
    
    if (self.contentType == QMAttachmentContentTypeVideo) {
        
        QMSLog(@"5 QMAttachmentContentTypeVideo %@", _messageID);
        NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoTracks.count > 0) {
            QMSLog(@"6 tracksWithMediaType %@", _messageID);
            AVAssetTrack *videoTrack = [videoTracks firstObject];
            CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
            CGFloat videoWidth = videoSize.width;
            CGFloat videoHeight = videoSize.height;
            
            mediaSize = CGSizeMake(videoWidth, videoHeight);
            
            QMSLog(@"7 Begin imnage generation %@", _messageID);
            __weak typeof(self) weakSelf = self;
            
            [self generateThumbnailFromAsset:asset withSize:mediaSize completionHandler:^(UIImage *thumbnail, NSError *error) {
                QMSLog(@"8 End image generation %@", _messageID);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.loaderStatus == QMAssetLoaderStatusCancelled) {
                    return;
                }
                if (error) {
                    if (strongSelf.completion) {
                        [strongSelf.preloadTimeout cancelTimeout];
                        strongSelf.loaderStatus = QMAssetLoaderStatusFinished;
                        strongSelf.completion(duration, mediaSize, thumbnail, error);
                    }
                    return;
                }
                
                strongSelf.loaderStatus = QMAssetLoaderStatusFinished;
                if (strongSelf.completion) {
                    [strongSelf.preloadTimeout cancelTimeout];
                    strongSelf.completion(duration, mediaSize, thumbnail, nil);
                }
            }];
        }
        else {
            
            QMSLog(@"6 NO tracksWithMediaType %@", _messageID);
            self.loaderStatus = QMAssetLoaderStatusFinished;
            if (self.completion) {
                [self.preloadTimeout cancelTimeout];
                self.completion(duration, mediaSize, nil , nil);
            }
        }
    }
    else {
        
        self.loaderStatus = QMAssetLoaderStatusFinished;
        [self.preloadTimeout cancelTimeout];
        self.completion(duration, mediaSize, nil, nil);
    }
}


- (void)cancel {
    
    NSParameterAssert(self.loaderStatus != QMAssetLoaderStatusCancelled);
    QMSLog(@"6 Call cancel for %@", _messageID);
    [_preloadTimeout cancelTimeout];
    _loaderStatus = QMAssetLoaderStatusCancelled;
    [_asset cancelLoading];
    [_imageGenerator cancelAllCGImageGeneration];
    _completion = nil;
}


@end
