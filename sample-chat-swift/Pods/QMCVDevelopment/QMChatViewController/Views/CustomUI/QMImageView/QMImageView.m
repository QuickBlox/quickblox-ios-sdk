//
//  QMImageView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "SDWebImageManager.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"

static NSString * const kQMImageViewTransformedKey = @"%@/original";
static NSString * const kQMImageViewScaleKey = @"%@/%lf-%lf";

static NSString * const kQMImageViewLoadOperationKey = @"UIImageViewImageLoad";

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

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    self = [super initWithImage:image];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    self = [super initWithImage:image highlightedImage:highlightedImage];
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
    
    [self.webManager setCacheKeyFilter:^(NSURL *url) {
        
        return [NSString stringWithFormat:kQMImageViewScaleKey, url.absoluteString, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)];
    }];
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
    
    if (url == nil) {
        
        NSError *error =
        [NSError errorWithDomain:@"SDWebImageErrorDomain"
                            code:-1
                        userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
        
        if (completedBlock) {
            
            completedBlock(nil, error, SDImageCacheTypeNone, url);
        }

    }
    
    NSString *key = [self.webManager cacheKeyForURL:url];
    
    UIImage *cachedImage = [self.webManager.imageCache imageFromMemoryCacheForKey:key];
    if (cachedImage != nil) {
        
        self.image = cachedImage;
        
        if (completedBlock) {
            
            completedBlock(cachedImage, nil, SDImageCacheTypeMemory, url);
        }
        
        return;
    }
    
    cachedImage = [self.webManager.imageCache imageFromDiskCacheForKey:key];
    if (cachedImage != nil) {
        
        self.image = cachedImage;
        
        if (completedBlock) {
            
            completedBlock(cachedImage, nil, SDImageCacheTypeDisk, url);
        }
        
        return;
    }
    
    cachedImage = [self originalImage];
    if (cachedImage != nil) {
        
        cachedImage = [self transformImage:cachedImage];
        self.image = cachedImage;
        [self.webManager saveImageToCache:cachedImage forURL:url];
        
        if (completedBlock) {
            
            completedBlock(cachedImage, nil, SDImageCacheTypeNone, url);
        }
        
        return;
    }
    
    // loading image cause it is not existent
    
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
    
    [self sd_setImageLoadOperation:operation forKey:kQMImageViewLoadOperationKey];
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    
    // saving original image if needed
    if (self.imageViewType != QMImageViewTypeNone) {
        
        [self.webManager.imageCache storeImage:image forKey:[NSString stringWithFormat:kQMImageViewTransformedKey, imageURL.absoluteString]];
    }
    
    UIImage *transformedImage = [self transformImage:image];
    return transformedImage;
}

- (UIImage *)transformImage:(UIImage *)image {
    
    if (self.imageViewType == QMImageViewTypeSquare) {
        
        return [image imageByScaleAndCrop:self.frame.size];
    }
    else if (self.imageViewType == QMImageViewTypeCircle) {
        
        if (image.size.height > image.size.width
            || image.size.width > image.size.height) {
            // if image is not square it will be disorted
            // making it a square-image first
            image = [image imageByScaleAndCrop:self.frame.size];
        }
        
        return [image imageByCircularScaleAndCrop:self.frame.size];
    }
    else {
        
        return image;
    }
}

- (UIImage *)originalImage {
    
    return [self.webManager.imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:kQMImageViewTransformedKey, self.url.absoluteString]];
}

- (void)removeImage {
    
    NSString *urlStr = self.url.absoluteString;
    [self.webManager.imageCache removeImageForKey:urlStr];
    [self.webManager.imageCache removeImageForKey:[NSString stringWithFormat:kQMImageViewTransformedKey, urlStr]];
    self.image = nil;
    self.url = nil;
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
