//
//  QMImageView.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "SDWebImageManager.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"

@interface QMImageView()

<SDWebImageManagerDelegate>

@property (strong, nonatomic) SDWebImageManager *webManager;

@end

@implementation QMImageView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configure];
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.masksToBounds = YES;
}

- (void)dealloc {
    [self sd_cancelCurrentImageLoad];
}

- (void)configure {
    
    self.webManager = [[SDWebImageManager alloc] init];
    self.webManager.delegate = self;
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    self.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock  {
    
    self.image = placehoder;
    
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &url, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        self.image = placehoder;
    }
    
    if (url) {
        
        __weak __typeof(self)weakSelf = self;
        id <SDWebImageOperation> operation = [self.webManager downloadImageWithURL:url options:options progress:progress completed:
                                              ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                  
                                                  if (!weakSelf) return;
                                                  dispatch_main_sync_safe(^{
                                                      
                                                      if (!weakSelf) return;
                                                      
                                                      if (weakSelf) {
                                                          
                                                          weakSelf.image = image;
                                                          [weakSelf setNeedsLayout];
                                                      }
                                                      else {
                                                          
                                                          if ((options & SDWebImageDelayPlaceholder)) {
                                                              weakSelf.image = placehoder;
                                                              [weakSelf setNeedsLayout];
                                                          }
                                                      }
                                                      
                                                      if (completedBlock && finished) {
                                                          completedBlock(image, error, cacheType, url);
                                                      }
                                                  });
                                              }];
        
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    }
    else {
        dispatch_main_async_safe(^{
            
            NSError *error =
            [NSError errorWithDomain:@"SDWebImageErrorDomain"
                                code:-1
                            userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager
 transformDownloadedImage:(UIImage *)image
                  withURL:(NSURL *)imageURL {
    
    return [self transformImage:image];
}

- (UIImage *)transformImage:(UIImage *)image {
    
    NSData *imageData = UIImagePNGRepresentation(image);
    UIImage *pngImage = [UIImage imageWithData:imageData];
    
    if (self.imageViewType == QMImageViewTypeSquare) {
        return [pngImage imageByScaleAndCrop:self.frame.size];
    }
    else if (self.imageViewType == QMImageViewTypeCircle) {
        return [pngImage imageByCircularScaleAndCrop:self.frame.size];
    } else {
        return pngImage;
    }
}

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key {
    
    UIImage *cachedImage = [[self.webManager imageCache] imageFromDiskCacheForKey:key];
    if (cachedImage) {
        self.image = cachedImage;
    }
    else {
        
        UIImage *img = [self transformImage:image];
        [[self.webManager imageCache] storeImage:img forKey:key];
        self.image = img;
    }
}

@end
