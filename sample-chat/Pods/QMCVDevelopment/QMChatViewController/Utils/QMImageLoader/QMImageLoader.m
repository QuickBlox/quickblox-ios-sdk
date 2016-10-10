//
//  QMImageLoader.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 9/12/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import "QMImageLoader.h"
#import "UIImage+Cropper.h"

static NSString * const kQMImageViewScaleKey = @"%@/%lf-%lf";
static NSString * const kQMImageViewTransformedKey = @"%@/original";

@implementation QMImageLoader

+ (id <SDWebImageOperation>)imageWithURL:(NSURL *)url
                                   frame:(CGRect)frame
                                 options:(SDWebImageOptions)options
                                progress:(SDWebImageDownloaderProgressBlock)progressBlock
                          transformImage:(QMImageLoaderTransformBlock)transformImage
                               completed:(SDWebImageCompletionBlock)completedBlock {
    
    if (url == nil) {
        
        NSError *error =
        [NSError errorWithDomain:@"SDWebImageErrorDomain"
                            code:-1
                        userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
        
        if (completedBlock != nil) {
            
            completedBlock(nil, error, SDImageCacheTypeNone, url);
        }
        
        return nil;
    }
    
    BOOL hasFrame = !CGRectIsEmpty(frame);
    
    NSString *originalKey = originalImageKey(url);
    NSString *key = hasFrame ? scaleImageKey(url, frame) : originalKey;
    __block UIImage *finalImage = nil;
    
    [[self class] cachedImageForKey:key completion:^(UIImage *image, SDImageCacheType cacheType) {
        
        finalImage = image;
        if (image != nil
            && completedBlock != nil) {
            
            completedBlock(image, nil, cacheType, url);
        }
    }];
    
    if (finalImage == nil) {
        // looking for original image to crop into final
        [[self class] cachedImageForKey:originalKey completion:^(UIImage *image, SDImageCacheType cacheType) {
            
            if (image != nil) {
                
                finalImage = [[self class] transformImage:image frame:frame transformBlock:transformImage];
                
                // storing image
                [webManager().imageCache storeImage:finalImage forKey:key];
                
                if (completedBlock != nil) {
                    
                    completedBlock(finalImage, nil, SDImageCacheTypeMemory, url);
                }
            }
        }];
    }
    
    if (finalImage != nil) {
        // requested image was found and delivered
        return nil;
    }
    
    return [webManager() downloadImageWithURL:url
                                      options:options
                                     progress:progressBlock
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        
                                        finalImage = image;
                                        if (finalImage != nil
                                            && hasFrame) {
                                            // transforming image for requested transform frame
                                            finalImage = [[self class] transformImage:image frame:frame transformBlock:transformImage];
                                            [webManager().imageCache storeImage:finalImage forKey:key];
                                        }
                                        
                                        if (completedBlock != nil) {
                                            
                                            completedBlock(finalImage, error, cacheType, imageURL);
                                        }
                                    }];
}

+ (void)cachedImageForKey:(NSString *)key completion:(SDWebImageQueryCompletedBlock)completion {
    
    [webManager().imageCache queryDiskCacheForKey:key done:completion];
}

+ (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    
    [webManager().imageCache storeImage:image forKey:key];
}

#pragma mark - Helpers

+ (UIImage *)transformImage:(UIImage *)image frame:(CGRect)frame transformBlock:(QMImageLoaderTransformBlock)block {
    
    if (block != nil) {
        // we have a specific transform for current image
        return block(image, frame);
    }
    
    // just a frame transform
    return [image imageByScaleAndCrop:frame.size];
}

static NSString *originalImageKey(NSURL *url) {
    
    return [NSString stringWithFormat:kQMImageViewTransformedKey, url.absoluteString];
}

static NSString *scaleImageKey(NSURL *url, CGRect frame) {
    
    return [NSString stringWithFormat:kQMImageViewScaleKey, url.absoluteString, CGRectGetWidth(frame), CGRectGetHeight(frame)];
}

static SDWebImageManager *webManager() {
    
    static SDWebImageManager *webManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        webManager = [[SDWebImageManager alloc] init];
        [webManager setCacheKeyFilter:^(NSURL *url) {
            
            return originalImageKey(url);
        }];
    });
    
    return webManager;
}

@end
