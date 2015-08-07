//
//  STKUtility.m
//  StickerFactory
//
//  Created by Vadim Degterev on 26.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKUtility.h"
#import <UIKit/UIKit.h>


NSString *const STKUtilityAPIUrl = @"http://api.stickerpipe.com/stk/";


@implementation STKUtility


#pragma mark -

+ (NSURL*) imageUrlForStikerMessage:(NSString *)stickerMessage {
    
    
    NSArray *separaredStickerNames = [self trimmedPackNameAndStickerNameWithMessage:stickerMessage];
    NSString *packName = [[separaredStickerNames firstObject] lowercaseString];
    NSString *stickerName = [[separaredStickerNames lastObject] lowercaseString];
    
    NSString *density = [self scaleString];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@_%@.png", packName, stickerName, density];
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:STKUtilityAPIUrl]];
    
    return url;
    
}

+ (NSArray*) trimmedPackNameAndStickerNameWithMessage:(NSString*)message {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSString *packNameAndStickerName = [message stringByTrimmingCharactersInSet:characterSet];
    
    NSArray *separaredStickerNames = [packNameAndStickerName componentsSeparatedByString:@"_"];
    return separaredStickerNames;
}

+ (NSURL *)tabImageUrlForPackName:(NSString *)name {
    
    NSString *density = [self scaleString];
    
    NSString *urlSting = [NSString stringWithFormat:@"%@/tab_icon_%@.png",name, density];
    
    NSURL *url = [NSURL URLWithString:urlSting relativeToURL:[NSURL URLWithString:STKUtilityAPIUrl]];
    
    return url;
}

+ (NSURL *)imageUrlForStickerPanelWithMessage:(NSString *)stickerMessage {
    NSArray *separaredStickerNames = [self trimmedPackNameAndStickerNameWithMessage:stickerMessage];
    NSString *packName = [[separaredStickerNames firstObject] lowercaseString];
    NSString *stickerName = [[separaredStickerNames lastObject] lowercaseString];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@_mdpi.png", packName, stickerName];
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:STKUtilityAPIUrl]];
    return url;
}

+ (NSString*) scaleString {
    
    NSInteger scale =  (NSInteger)[[UIScreen mainScreen]scale];
    
    NSString *dimension = nil;
    
    //Android style scale
    switch (scale) {
            case 1:
            dimension = @"mdpi";
            break;
            case 2:
            dimension = @"xhdpi";
            break;
            case 3:
            dimension = @"xxhdpi";
            break;
            
        default:
            break;
    }
    return dimension;
}

#pragma mark - Colors

+ (UIColor*) defaultGrayColor {
    return [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1];
}

#pragma mark - STKLog

void STKLog(NSString *format, ...) {

#if DEBUG
    
    va_list argumentList;
    va_start(argumentList, format);
    
    NSLogv(format, argumentList);
    
    va_end(argumentList);
    
#endif
}


@end
