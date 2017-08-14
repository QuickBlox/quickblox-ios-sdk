//
//  QMImageLoader.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 9/12/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import "QMImageLoader.h"

@interface QMImageLoader() <SDWebImageManagerDelegate>

@property (strong, nonatomic) NSMutableDictionary *imagePorcessors;

@end

@implementation QMImageLoader

+ (instancetype)instance {
    
    static dispatch_once_t onceToken;
    static QMImageLoader *_loader = nil;
    dispatch_once(&onceToken, ^{
        
        SDImageCache *qmCache =
        [[SDImageCache alloc] initWithNamespace:@"default"];
        qmCache.shouldCacheImagesInMemory = YES;
        
        SDWebImageDownloader *qmDownloader =
        [[SDWebImageDownloader alloc] init];
        _loader =
        [[QMImageLoader alloc] initWithCache:qmCache
                                  downloader:qmDownloader];
        
        qmDownloader.maxConcurrentDownloads = 4;
        _loader.imagePorcessors = [NSMutableDictionary dictionary];
        
//        _loader.thumbnailsCache =
//        [[SDImageCache alloc] initWithNamespace:@"qm.thumbnails"];
//        _loader.thumbnailsCache.shouldDecompressImages = NO;
//        _loader.thumbnailsCache.shouldCacheImagesInMemory = YES;
        
    });
    
    return _loader;
}

- (instancetype)initWithCache:(SDImageCache *)cache
                   downloader:(SDWebImageDownloader *)downloader {
 
    self = [super initWithCache:cache downloader:downloader];
    if (self) {
        
        self.delegate = self;
    }
    
    return self;
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                       transform:(id <SDWebImageManagerDelegate>)transform
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    if (transform) {
        _imagePorcessors[url] = transform;
    }
    
    id <SDWebImageOperation> operation =
     [super downloadImageWithURL:url
                        options:options
                       progress:progressBlock
                      completed:completedBlock];
    
    return operation;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager
 transformDownloadedImage:(UIImage *)image
                  withURL:(NSURL *)imageURL {
    
    id <SDWebImageManagerDelegate> processor = _imagePorcessors[imageURL];
    if (processor) {
        
        return [processor imageManager:imageManager
              transformDownloadedImage:image
                               withURL:imageURL];
    }
    
    return image;
}

@end
