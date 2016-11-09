//
//  QMImageLoader.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 9/12/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>

typedef UIImage *(^QMImageLoaderTransformBlock)(UIImage *image, CGRect frame);

/**
 *  QMImageLoader class interface.
 *  This class is responsible for image caching, loading and size handling using
 *  SDWebImage component.
 */
@interface QMImageLoader : NSObject

/**
 *  Image with URL.
 *
 *  @param url            image url
 *  @param frame          image frame (pass CGRectZero if you want original size image)
 *  @param options        SDWebImageOptions
 *  @param progressBlock  progress block
 *  @param transformImage transform block (perform your own transformation here using passed frame)
 *  @param completedBlock completion block
 *
 *  @discussion Method will look for image in cache first. Will transform image if there is original one and no
 *  a secific one yet. Will load image if neither cached or original image existent.
 *
 *  @return SDWebImageOperation to manage your own operation queues.
 */
+ (id <SDWebImageOperation>)imageWithURL:(NSURL *)url
                                   frame:(CGRect)frame
                                 options:(SDWebImageOptions)options
                                progress:(SDWebImageDownloaderProgressBlock)progressBlock
                          transformImage:(QMImageLoaderTransformBlock)transformImage
                               completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  Looking for cached image in memory and disk for a specific key.
 *
 *  @param key          image key
 *  @param completion   completion block with cached image (if existent) and cache type
 */
+ (void)cachedImageForKey:(NSString *)key completion:(SDWebImageQueryCompletedBlock)completion;

/**
 *  Store image in memory and disk cache for a specific key.
 *
 *  @param image image to store
 *  @param key   key
 */
+ (void)storeImage:(UIImage *)image forKey:(NSString *)key;

@end
