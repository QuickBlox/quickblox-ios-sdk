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
@interface QMImageLoader : SDWebImageManager

+ (instancetype)instance;

+ (SDWebImageManager *)sharedManager NS_UNAVAILABLE;

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                       transform:(id <SDWebImageManagerDelegate>)transform
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;


@end
