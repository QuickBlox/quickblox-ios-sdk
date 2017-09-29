//
//  QMImageView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Cropper.h"
#import "objc/runtime.h"
#import "QMImageLoader.h"

@interface QMTextLayer : CALayer

- (void)setString:(NSString *)string color:(UIColor *)color;

@end

@implementation QMTextLayer {
    
    UIColor *_fillColor;
    NSString *_string;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.shouldRasterize = YES;
        self.rasterizationScale = [UIScreen mainScreen].scale;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setDrawsAsynchronously:YES];
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    
    CGRect rect = self.bounds;
    
    UIColor *color = [UIColor colorWithWhite:1 alpha:0.8];
    UIFont *font = [UIFont systemFontOfSize:rect.size.height * 0.4];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *defaultStyle = @{NSParagraphStyleAttributeName:style,
                                   NSForegroundColorAttributeName:color,
                                   NSFontAttributeName:font};
    
    UIGraphicsPushContext(ctx);
    
    CGSize size = CGSizeMake(self.bounds.size.width,
                             font.lineHeight);
    rect.origin.y = (rect.size.height - size.height) / 2.f;
    
    CGContextSetFillColorWithColor(ctx, _fillColor.CGColor);
    CGContextFillEllipseInRect(ctx, self.bounds);
    
    NSRange r = [_string rangeOfComposedCharacterSequenceAtIndex:0];
    NSString *firstCharacter = [[_string substringWithRange:r] capitalizedString];
    [firstCharacter drawInRect:rect withAttributes:defaultStyle];
    
    UIGraphicsPopContext();
}

- (void)setString:(NSString *)string color:(UIColor *)color {
    
    if (![_string isEqualToString:string]) {
        _string = [string copy];
        _fillColor = color;
        [self setNeedsDisplay];
    }
}

@end

@interface QMImageView()

@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) QMTextLayer *textLayer;
@property (strong, nonatomic) NSURL *imageUrl;

@end

@implementation QMImageView

static NSArray *qm_colors = nil;

//MARK: Initialization

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        qm_colors =
        @[[UIColor colorWithRed:1.0f green:0.588f blue:0 alpha:1.0f],
          [UIColor colorWithRed:0.267f green:0.859f blue:0.369f alpha:1.0f],
          [UIColor colorWithRed:0.329f green:0.780f blue:0.988f alpha:1.0f],
          [UIColor colorWithRed:1.0f green:0.176f blue:0.333f alpha:1.0f],
          [UIColor colorWithRed:0.608f green:0.184f blue:0.682f alpha:1.0f],
          [UIColor colorWithRed:0.082f green:0.584f blue:0.533f alpha:1.0f],
          [UIColor colorWithRed:0 green:0.478f blue:1.0f alpha:1.0f],
          [UIColor colorWithRed:0.804f green:0.855f blue:0.286f alpha:1.0f],
          [UIColor colorWithRed:0.122f green:0.737f blue:0.823f alpha:1.0f],
          [UIColor colorWithRed:0.251f green:0.329f blue:0.698f alpha:1.0f]];
    });
}

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

//MARK: - NSObject

- (void)dealloc {
    [self sd_cancelCurrentAnimationImagesLoad];
}

//MARK: - Public interface

- (UIImage *)originalImage {
    return self.image;
}

- (void)setImageWithURL:(NSURL *)url {
    
    [self setImageWithURL:url
              placeholder:nil
                  options:(SDWebImageHighPriority | SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates)
                 progress:nil
           completedBlock:nil];
}

- (void)setImageWithURL:(NSURL *)url
                  title:(NSString *)title
         completedBlock:(SDExternalCompletionBlock)completedBlock {
    
    BOOL urlIsValid = url &&url.scheme && url.host;
    
    dispatch_block_t showPlaceholder = ^{
        
        [_textLayer setString:title color:[self colorForString:title]];
        _textLayer.hidden = NO;
        
        if (!CGRectEqualToRect(_textLayer.frame, self.bounds)) {
            _textLayer.frame = self.bounds;
        }
    };
    
    if ([_url isEqual:url] && !self.image) {
        showPlaceholder();
        return;
    }
    
    _url = url;
    
    [self sd_cancelCurrentAnimationImagesLoad];
    
    CGSize targetSize = self.bounds.size;
    QMImageTransformType type = self.imageViewType == QMImageViewTypeCircle ?  QMImageTransformTypeCircle : QMImageTransformTypeCustom;
    QMImageTransform *transform;
    if (type == QMImageTransformTypeCircle)
    transform =
    [QMImageTransform transformWithType:type size:targetSize];
    
    else if (type == QMImageTransformTypeCustom) {
        
    transform =
        [QMImageTransform transformWithSize:targetSize
                       customTransformBlock:^UIImage *(NSURL *imageURL, UIImage *originalImage) {
            return [originalImage imageWithCornerRadius:4.0 targetSize:targetSize];
        }];
    }
    
    self.image = nil;
    showPlaceholder();
    
    if (urlIsValid) {
        
        __weak __typeof(self)weakSelf = self;
        
        id <SDWebImageOperation> operation =
        [[QMImageLoader instance]
         downloadImageWithURL:url
         transform:transform
         options:(SDWebImageHighPriority | SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates)
         progress:nil
         completed:
         ^(UIImage *image, UIImage *transfomedImage,
           NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (!weakSelf) return;
             
             if (!error) {
                 
                 if (transfomedImage) {
                     weakSelf.textLayer.hidden = YES;
                     weakSelf.image = transfomedImage;
                     [weakSelf setNeedsLayout];
                 }
             }
             
             if (completedBlock) {
                 completedBlock(image, error, cacheType, imageURL);
             }
         }];
        
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewAnimationImages"];
    }
    else {
        
        dispatch_main_async_safe(^{
            
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain
                                                     code:-1
                                                 userInfo:@
                                  {
                                      NSLocalizedDescriptionKey : @"Trying to load a nil url"
                                  }];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDExternalCompletionBlock)completedBlock  {
    
    BOOL urlIsValid = url &&url.scheme && url.host;
    
    _url = url;
    
    [self sd_cancelCurrentAnimationImagesLoad];
    
    self.image = placehoder;
    
    if (urlIsValid) {
        
        __weak __typeof(self)weakSelf = self;
        
        id <SDWebImageOperation> operation =
        [[QMImageLoader instance]
         downloadImageWithURL:url
         transform:nil
         options:options
         progress:nil
         completed:
         ^(UIImage *image, UIImage *transfomedImage,
           NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (!weakSelf) return;
             
             if (!error) {
                 
                 if (image) {
                     weakSelf.image = image;
                     [weakSelf setNeedsLayout];
                 }
             }
             
             if (completedBlock) {
                 completedBlock(image, error, cacheType, imageURL);
             }
         }];
    
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    }
    else {
        
        dispatch_main_async_safe(^{
            
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain
                                                     code:-1
                                                 userInfo:@
                                  {
                                      NSLocalizedDescriptionKey : @"Trying to load a nil url"
                                  }];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

//MARK: - UIView

- (CGSize)intrinsicContentSize {
    
    if (self.image) {
        return [super intrinsicContentSize];
    }
    
    return CGSizeZero;
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

//MARK: - Helpers

- (void)configure {
    
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTapGesture:)];
    
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
    self.userInteractionEnabled = YES;
    
    _textLayer = [[QMTextLayer alloc] init];
    _textLayer.frame = self.bounds;
    _textLayer.hidden = YES;
    
    [self.layer addSublayer:_textLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textLayer.frame = self.bounds;
}

- (UIColor *)colorForString:(NSString*)string {
    
    if (!string) {
        string = @"";
    }
    
    unsigned long hashNumber = stringToLong((unsigned char*)[string UTF8String]);
    
    return qm_colors[hashNumber % qm_colors.count];
}

unsigned long stringToLong(unsigned char* str) {
    
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

@end
