//
//  UIImageView+Stickers.m
//  StickerFactory
//
//  Created by Vadim Degterev on 24.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "UIImageView+Stickers.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "STKUtility.h"
#import <objc/runtime.h>
#import "UIImage+Tint.h"
#import "STKStickersManager.h"

@implementation UIImageView (Stickers)

#pragma mark - Builder

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage completion:(STKCompletionBlock)completion {
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:nil placeholderColor:nil progress:nil completion:completion];
    
}


- (void) stk_setStickerWithMessage:(NSString *)stickerMessage placeholder:(UIImage *)placeholder {
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:placeholder placeholderColor:nil progress:nil completion:nil];
}

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage
                   placeholder:(UIImage *)placeholder
                    completion:(STKCompletionBlock)completion
{
    
    [self stk_setStickerWithMessage:stickerMessage placeholder:placeholder placeholderColor:nil progress:nil completion:completion];
}

#pragma mark - Sticker Download

- (void) stk_setStickerWithMessage:(NSString *)stickerMessage
                       placeholder:(UIImage *)placeholder
                  placeholderColor:(UIColor*)placeholderColor
                          progress:(STKDownloadingProgressBlock)progressBlock
                        completion:(STKCompletionBlock)completion {
    
    
    NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:stickerMessage];
    UIImage *placeholderImage = nil;
    if (!placeholder) {
        UIImage *defaultPlaceholder = [UIImage imageNamed:@"StickerPlaceholder"];
        if (placeholderColor) {
            defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:placeholderColor];
        } else {
            defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:[STKUtility defaultGrayColor]];
        }
        placeholderImage = defaultPlaceholder;

    } else {
        placeholderImage = placeholder;
    }
    
    [self sd_setImageWithURL:stickerUrl placeholderImage:placeholderImage options:SDWebImageHighPriority progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            STKLog(@"Cannot download sticker from category with error: %@", error.localizedDescription);
        }
        if (completion) {
            completion(error, image);
        }
        
    }];
    
}

#pragma mark - Stop loading

- (void)stk_cancelStickerLoading {
    
    [self sd_cancelCurrentImageLoad];
}

@end
