//
//  STKStickersClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersManager.h"
#import <SDWebImageManager.h>
#import "STKUtility.h"
#import "STKAnalyticService.h"
#import "STKApiKeyManager.h"

//Colors

static UIColor *displayedPlaceholderColor;
static UIColor *panelPlaceholderColor;
static UIColor *panelHeaderPlaceholderColor;


@interface STKStickersManager()

@property (strong, nonatomic) SDWebImageManager *imageManager;

@end

@implementation STKStickersManager

- (void)getStickerForMessage:(NSString *)message progress:(void (^)(NSInteger, NSInteger))progress success:(void (^)(UIImage *))success failure:(void (^)(NSError *, NSString *))failure {
    
    if ([self.class isStickerMessage:message]) {
        NSURL *stickerUrl = [STKUtility imageUrlForStikerMessage:message];
        
        [self.imageManager downloadImageWithURL:stickerUrl
                                        options:0
                                       progress:progress
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                          if (error) {
                                              if (failure) {
                                                  failure(error, nil);
                                                  STKLog(@"Cannot download sticker from STKStickerManager");
                                              }
                                          } else {
                                              if (success) {
                                                  success(image);
                                              }
                                          }
                                      }];
    } else {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"It's not a sticker" code:999 userInfo:nil];
            failure(error, @"It's not a sticker");
        }
    }

}

#pragma mark - Validation

+ (BOOL)isStickerMessage:(NSString *)message {
    NSString *regexPattern = @"^\\[\\[[a-zA-Z0-9]+_[a-zA-Z0-9]+\\]\\]$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexPattern];
    
    BOOL isStickerMessage = [predicate evaluateWithObject:message];
    
    STKAnalyticService *service = [STKAnalyticService sharedService];
    
    if (isStickerMessage) {
        
        [service sendEventWithCategory:STKAnalyticMessageCategory action:STKAnalyticActionCheck label:@"Stickers count" value:@(1)];
        
    } else {
        [service sendEventWithCategory:STKAnalyticMessageCategory action:STKAnalyticActionCheck label:@"Events count" value:@(1)];
    }
    
    return isStickerMessage;
}


#pragma mark - ApiKey

+(void)initWitApiKey:(NSString *)apiKey {
    [STKApiKeyManager setApiKey:apiKey];
}

#pragma mark - Properties

- (SDWebImageManager *)imageManager {
    
    return [SDWebImageManager sharedManager];
}

#pragma mark - Set Colors

+ (void)setColorForDisplayedStickerPlaceholder:(UIColor *)color {
    if (displayedPlaceholderColor != color) {
        displayedPlaceholderColor = color;
    }
}

+ (void)setColorForPanelHeaderPlaceholderColor:(UIColor *)color {
    if (panelHeaderPlaceholderColor != color) {
        panelHeaderPlaceholderColor = color;
    }
}

+ (void)setColorForPanelPlaceholder:(UIColor *)color {
    if (panelPlaceholderColor != color) {
        panelPlaceholderColor = color;
    }
}

#pragma mark - Get Colors

+ (UIColor *)displayedStickerPlaceholderColor {
    return displayedPlaceholderColor;
}

+ (UIColor *)panelPlaceholderColor {
    return panelPlaceholderColor;
}

+ (UIColor *)panelHeaderPlaceholderColor {
    return panelHeaderPlaceholderColor;
}

@end
