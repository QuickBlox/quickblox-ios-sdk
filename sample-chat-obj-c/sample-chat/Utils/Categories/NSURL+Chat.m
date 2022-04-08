//
//  NSURL+Chat.m
//  sample-chat
//
//  Created by Injoit on 06.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "NSURL+Chat.h"
#import <Photos/Photos.h>

@implementation NSURL (Chat)
- (void)getThumbnailImageFromVideoUrlWithCompletion:(void(^)(UIImage *image))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *avAsset = [AVAsset assetWithURL:self];
        AVAssetImageGenerator *avAssetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
        avAssetImageGenerator.appliesPreferredTrackTransform = YES;
        NSError *error = NULL;
        CMTime thumnailTime = CMTimeMake(2, 1);
        CGImageRef cgThumbImage = [avAssetImageGenerator copyCGImageAtTime:thumnailTime actualTime:NULL error:&error];
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([UIImage imageNamed:@"video_attachment"]);
                });
            }
        } else {
            UIImage *thumbImage = [[UIImage alloc] initWithCGImage:cgThumbImage];
            if (!thumbImage) {
                thumbImage = [UIImage imageNamed:@"video_attachment"];
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(thumbImage);
                });
            }
        }
    });
}

- (void)imageFromPDFfromURLWithCompletion:(void(^)(UIImage *image))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFURLRef cfURLRef = CFBridgingRetain(self);
        CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL(cfURLRef);
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
        CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
        
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:pageRect.size];
        UIImage *thumbImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [UIColor.whiteColor set];
            [rendererContext fillRect:pageRect];
            CGContextTranslateCTM(rendererContext.CGContext, 0.0f, pageRect.size.height);
            CGContextScaleCTM(rendererContext.CGContext, 1, -1);
            CGContextDrawPDFPage(rendererContext.CGContext, pageRef);
        }];
        if (!thumbImage) {
            thumbImage = [UIImage imageNamed:@"file"];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(thumbImage);
            });
        }
    });
}

@end
