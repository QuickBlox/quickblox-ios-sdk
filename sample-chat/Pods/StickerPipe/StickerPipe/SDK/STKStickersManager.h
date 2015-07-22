//
//  STKStickersClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface STKStickersManager : NSObject

+ (void) initWitApiKey:(NSString*) apiKey;

- (void) getStickerForMessage:(NSString*) message
                     progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize)) progress
                      success:(void(^)(UIImage *sticker))success
                      failure:(void(^)(NSError *error, NSString *errorMessage)) failure;

+ (BOOL) isStickerMessage:(NSString*) message;


//Color settings. Default is light gray

+ (void) setColorForDisplayedStickerPlaceholder:(UIColor*) color;

+ (void) setColorForPanelPlaceholder:(UIColor*) color;

+ (void) setColorForPanelHeaderPlaceholderColor:(UIColor*) color;


+ (UIColor*) displayedStickerPlaceholderColor;

+ (UIColor*) panelPlaceholderColor;

+ (UIColor*) panelHeaderPlaceholderColor;


@end
