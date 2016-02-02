//
//  QMImageView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "SDWebImageManager.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"

@interface QMImageView()

<SDWebImageManagerDelegate>

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) SDWebImageManager *webManager;
@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

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
}

- (void)dealloc {
    
    [self sd_cancelCurrentImageLoad];
}

- (void)configure {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    self.layer.borderWidth = self.borderWidth;
    
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
    self.userInteractionEnabled = YES;
    
    self.webManager = [[SDWebImageManager alloc] init];
    self.webManager.delegate = self;
}

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock  {
    
    if ([url isEqual:self.url]) {
        return;
    }
    
    self.url = url;
    
    [self sd_cancelCurrentImageLoad];
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        self.image = placehoder;
    }
    
    if (url) {
        
        __weak __typeof(self)weakSelf = self;
        
        id <SDWebImageOperation> operation =
        [self.webManager downloadImageWithURL:url options:options progress:progress
                                    completed:
         ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             
             if (!weakSelf) return;
             
             dispatch_main_sync_safe(^{
                 
                 if (!error) {
                     
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
                     completedBlock(image, error, cacheType, imageURL);
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

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    
    UIImage *transformedImage = [self transformImage:image];
    return transformedImage;
}

- (UIImage *)transformImage:(UIImage *)image {
    
    if (self.imageViewType == QMImageViewTypeSquare) {
        
        return [image imageByScaleAndCrop:self.frame.size];
    }
    else if (self.imageViewType == QMImageViewTypeCircle) {
        
        return [image imageByCircularScaleAndCrop:self.frame.size];
    }
    else {
        
        return image;
    }
}

- (void)setImage:(UIImage *)image withKey:(NSString *)key {
    
    UIImage *cachedImage = [[self.webManager imageCache] imageFromDiskCacheForKey:key];
    if (cachedImage) {
        
        self.image = cachedImage;
    }
    else {
        
        [self applyImage:image];
        [[self.webManager imageCache] storeImage:self.image forKey:key];
    }
}

- (void)applyImage:(UIImage *)image {
    
    UIImage *img = [self transformImage:image];
    self.image = img;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.delegate respondsToSelector:@selector(imageViewDidTap:)]) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.layer.opacity = 0.6;
            
        } completion:^(BOOL finished) {
            
            self.layer.opacity = 1;
            
            [self.delegate imageViewDidTap:self];
        }];
    }
}

@end
