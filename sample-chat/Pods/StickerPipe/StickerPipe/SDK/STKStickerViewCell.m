//
//  STKStickerPanelCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerViewCell.h"
#import "UIImageView+Stickers.h"
#import "UIImage+Tint.h"
#import "STKUtility.h"
#import "DFImageManagerKit.h"
#import <SDWebImage/SDWebImageManager.h>
#import "STKStickerObject.h"
#import "STKImageManager.h"
#import "UIImageView+WebCache.h"
#import "STKStickersApiService.h"

@interface STKStickerViewCell()

@property (strong, nonatomic) UIImageView *stickerImageView;
@property (strong, nonatomic) DFImageTask *imageTask;

@end

@implementation STKStickerViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.stickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
        self.stickerImageView.contentMode = UIViewContentModeRedraw;
        [self addSubview:self.stickerImageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
}

- (void)prepareForReuse {
    [self.imageTask cancel];
    self.imageTask = nil;
    self.stickerImageView.image = nil;
    [self.stickerImageView sd_cancelCurrentAnimationImagesLoad];
    [[SDWebImageManager sharedManager] cancelAll];
}

- (void) configureWithStickerMessage:(NSString*)stickerMessage
                         placeholder:(UIImage*)placeholder
                    placeholderColor:(UIColor*)placeholderColor {
    UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed:@"STKStickerPanelPlaceholder"];
    
    UIColor *colorForPlaceholder = placeholderColor && !placeholder ? placeholderColor : [STKUtility defaultPlaceholderGrayColor];
    
    UIImage *coloredPlaceholder = [resultPlaceholder imageWithImageTintColor:colorForPlaceholder];
    
//    NSURL *stickerUrl = [STKUtility imageUrlForStickerPanelWithMessage:stickerMessage];
    NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:stickerMessage andDensity:[STKUtility scaleString]];
    
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.priority = DFImageRequestPriorityNormal;
    
    self.stickerImageView.image = coloredPlaceholder;
    [self setNeedsLayout];
    
    DFImageRequest *request = [DFImageRequest requestWithResource:stickerUrl targetSize:CGSizeZero contentMode:DFImageContentModeAspectFit options:options];
    
    __weak typeof(self) weakSelf = self;
    
    //TODO:MOVE TASK TO MODEL
    
//    self.imageTask =[[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
//        if (image) {
//            weakSelf.stickerImageView.image = image;
//            [weakSelf setNeedsLayout];
//        } else {
//            NSError *error = info[DFImageInfoErrorKey];
//            if (error && error.code != -1) {
//                STKLog(@"Failed loading from stickerView cell: %@", error.localizedDescription);
//            }
//        }
//    }];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSString *stickerName = [stickerMessage stringByTrimmingCharactersInSet:characterSet];

    [[SDImageCache sharedImageCache] queryDiskCacheForKey:stickerName done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.stickerImageView.image = image;
            [weakSelf setNeedsLayout];
        }
        else {
            STKStickersApiService *stickersApiService = [STKStickersApiService new];
            [stickersApiService getStickerInfoWithId:stickerName success:^(id response) {
                
                NSString *urlString = response[@"data"][@"image"][[STKUtility scaleString]];
                
                SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                
                [downloader downloadImageWithURL: [NSURL URLWithString:urlString]
                                         options:0
                                        progress:nil
                                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                           if (image && finished) {
                                               
                                               [[SDImageCache sharedImageCache] storeImage:image forKey:stickerName];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   weakSelf.stickerImageView.image = image;
                                                   [weakSelf setNeedsLayout];
                                               });
                                             
                                           }
                                       }];
            } failure:nil];
        }

    }];
    

    
    [self.imageTask resume];
            
}

@end
