//
//  QMImageLoader.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 9/12/16.
//  Copyright (c) 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>
#import "UIImage+Cropper.h"

NS_ASSUME_NONNULL_BEGIN

typedef UIImage  * _Nullable (^QMCustomTransformBlock)(NSURL *imageURL, UIImage *originalImage);

typedef NS_ENUM(NSInteger, QMImageTransformType) {
    
    QMImageTransformTypeScaleAndCrop = 0,
    QMImageTransformTypeCircle,
    QMImageTransformTypeRounding,
    QMImageTransformTypeCustom
};


@interface QMImageTransform : NSObject

+ (instancetype)transformWithType:(QMImageTransformType)transformType
                             size:(CGSize)size;

+ (instancetype)transformWithSize:(CGSize)size customTransformBlock:(QMCustomTransformBlock)customTransformBlock;
+ (instancetype)transformWithSize:(CGSize)size isCircle:(BOOL)isCircle; //deprecate???
- (void)applyTransformForImage:(UIImage *)image completionBlock:(void(^)(UIImage *transformedImage))transformCompletionBlock;
- (NSString *)keyWithURL:(NSURL *)url;

@end

typedef void(^QMWebImageCompletionWithFinishedBlock)(UIImage *_Nullable image, UIImage *_Nullable transfomedImage, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL);

/**
 *  QMImageLoader class interface.
 *  This class is responsible for image caching, loading and size handling using
 *  SDWebImage component.
 */
@interface QMImageLoader : SDWebImageManager

@property (nonatomic, readonly, class) QMImageLoader *instance;


+ (SDWebImageManager *)sharedManager NS_UNAVAILABLE;

- (UIImage *)originalImageWithURL:(NSURL *)url;
- (BOOL)hasOriginalImageWithURL:(NSURL *)url;
- (NSString *)pathForOriginalImageWithURL:(NSURL *)url;


- (BOOL)hasImageOperationWithURL:(NSURL *)url;
- (id<SDWebImageOperation>)operationWithURL:(NSURL *)url;
- (void)cancelOperationWithURL:(NSURL *)url;

- (id<SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                       transform:(nullable QMImageTransform *)transform
                                         options:(SDWebImageOptions)options
                                        progress:(_Nullable SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(QMWebImageCompletionWithFinishedBlock)completedBlock;

- (id<SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                           token:(nullable NSString *)token
                                       transform:(QMImageTransform *)transform
                                         options:(SDWebImageOptions)options
                                        progress:(_Nullable SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(QMWebImageCompletionWithFinishedBlock)completedBlock;
@end

NS_ASSUME_NONNULL_END
