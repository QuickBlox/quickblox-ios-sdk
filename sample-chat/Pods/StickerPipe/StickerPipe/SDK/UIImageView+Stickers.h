//
//  UIImageView+Stickers.h
//  StickerFactory
//
//  Created by Vadim Degterev on 24.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^STKCompletionBlock)(NSError *error, UIImage *stickerImage);
typedef void(^STKDownloadingProgressBlock)(NSTimeInterval progress);

@interface UIImageView (Stickers)

- (void) stk_setStickerWithMessage:(NSString*)stickerMessage
                     completion:(STKCompletionBlock) completion;

- (void) stk_setStickerWithMessage:(NSString*)stickerMessage
                    placeholder:(UIImage*)placeholder;


- (void) stk_setStickerWithMessage:(NSString*)stickerMessage
                    placeholder:(UIImage*)placeholder
                     completion:(STKCompletionBlock) completion;


- (void) stk_setStickerWithMessage:(NSString *)stickerMessage
                    placeholder:(UIImage *)placeholder
                  placeholderColor:(UIColor*)placeholderColor
                       progress:(STKDownloadingProgressBlock)progressBlock
                     completion:(STKCompletionBlock)completion;




- (void) stk_cancelStickerLoading;

- (void) stk_cancelStickerImageLoading:(UIImageView *)stickerImageView;

@end
