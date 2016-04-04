//
//  STKImageManager.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 3/1/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKImageManager.h"
#import "STKUtility.h"
#import <objc/runtime.h>
#import <SDWebImage/SDWebImageManager.h>
#import "STKStickersApiService.h"

@implementation STKImageManager

//- (void)getImageForStickerMessage:(NSString *)stickerMessage andDensity:(NSString *)density withProgress:(STKDownloadingProgressBlock)progressBlock andCompletion:(STKCompletionBlock)completion {
//
//    NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:stickerMessage andDensity:density];
//
//    DFImageRequestOptions *options = [DFImageRequestOptions new];
//    options.allowsClipping = YES;
//    options.progressHandler = ^(double progress){
//        // Observe progress
//        if (progressBlock) {
//            progressBlock(progress);
//        }
//    };
//
//    DFImageRequest *request = [DFImageRequest requestWithResource:stickerUrl targetSize:CGSizeZero contentMode:DFImageContentModeAspectFit options:options];
//
//    self.imageTask = [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
//        NSError *error = info[DFImageInfoErrorKey];
//
//        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
//        NSString *stickerName = [stickerMessage stringByTrimmingCharactersInSet:characterSet];
//        SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"myNamespace"];
//       [imageCache queryDiskCacheForKey:stickerName done:^(UIImage *image, SDImageCacheType cacheType) {
//           if (image) {
//               completion(nil, image);
//           }
//
//       }];
//
////        if (completion) {
////            completion(error, image);
//       // }
//    }];
//    [self.imageTask resume];
//
//}

- (DFImageTask *)imageTask {
    return objc_getAssociatedObject(self, @selector(imageTask));
}

- (void)setImageTask:(DFImageTask *)imageTask {
    objc_setAssociatedObject(self, @selector(imageTask), imageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelLoading {
    [self.imageTask cancel];
}

- (void)getImageForStickerMessage:(NSString *)stickerMessage
                       andDensity:(NSString *)density withProgress:(STKDownloadingProgressBlock)progressBlock andCompletion:(STKCompletionBlock)completion {
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSString *stickerName = [stickerMessage stringByTrimmingCharactersInSet:characterSet];
    SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"myNamespace"];
    
    [imageCache queryDiskCacheForKey:stickerName done:^(UIImage *image,
                                                        SDImageCacheType cacheType) {
        if (image) {
            completion(nil, image);
        }
        else {
            STKStickersApiService *stickersApiService = [STKStickersApiService new];
            [stickersApiService getStickerInfoWithId:stickerName success:^(id response) {
            
            NSString *urlString = response[@"data"][@"image"][density];
                
            SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
            
            [downloader downloadImageWithURL: [NSURL URLWithString:urlString]
                                         options:0
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize)
                 {
                     if (progressBlock) {
                         progressBlock(receivedSize);
                     }
                     
                 }
                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                         if (image && finished) {
                                               
                                               [[SDImageCache sharedImageCache] storeImage:image forKey:stickerName];
                                               if (completion) {
                                                   completion (nil, image);
                                               }
                                           }
                                       }];
            } failure:nil];
        }
        
    }];
}

@end
