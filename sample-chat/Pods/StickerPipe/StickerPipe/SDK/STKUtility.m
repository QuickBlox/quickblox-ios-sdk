//
//  STKUtility.m
//  StickerFactory
//
//  Created by Vadim Degterev on 26.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKUtility.h"
#import "STKAnalyticService.h"


NSString *const STKUtilityAPIUrl = @"https://api.stickerpipe.com/stk/";
//NSString *const STKUtilityAPIUrl = @"http://work.stk.908.vc/stk/";

@implementation STKUtility


#pragma mark -

+ (NSURL*) imageUrlForStikerMessage:(NSString *)stickerMessage andDensity:(NSString *)density {
    
    
    NSArray *separaredStickerNames = [self trimmedPackNameAndStickerNameWithMessage:stickerMessage];
    NSString *packName = [[separaredStickerNames firstObject] lowercaseString];
    NSString *stickerName = [[separaredStickerNames lastObject] lowercaseString];
    
  //  NSString *density = [self scaleString];
    
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

+ (NSString *)stickerIdWithMessage:(NSString *)message {
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];

    return [message stringByTrimmingCharactersInSet:characterSet];
}

+ (NSURL *)tabImageUrlForPackName:(NSString *)name {
    
    NSString *density = [self scaleString];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/tab_icon_%@.png",name, density];
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:STKUtilityAPIUrl]];
    
    return url;
}

+ (NSURL *)mainImageUrlForPackName:(NSString *)name {
    
    NSString *density = [self scaleString];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/main_icon_%@.png",name, density];
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:STKUtilityAPIUrl]];
    
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

+(NSString*)maxDensity {
    return @"xxhdpi";
}

+ (NSString*)scaleString {
    
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

+ (UIColor*)defaultOrangeColor {
    return [UIColor colorWithRed:1 green:0.34 blue:0.13 alpha:1];
}

+ (UIColor*)defaultGreyColor {
    return [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
}

+ (UIColor*) defaultPlaceholderGrayColor {
    return [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1];
}

+ (UIColor*)defaultBlueColor {
    return [UIColor colorWithRed:4/255.0 green:122/255.0 blue:1. alpha:1];
}
#pragma mark - STKLog

void STKLog(NSString *format, ...) {
    
    va_list argumentList;
    va_start(argumentList, format);
#if DEBUG

    NSLogv(format, argumentList);
#endif
//    NSString *log = [[NSString alloc] initWithFormat:format arguments:argumentList];
//    
//    [[STKAnalyticService sharedService] sendDevEventWithCategory:STKAnalyticDevCategory action:STKAnalyticActionError label:log value:nil];
    
    va_end(argumentList);
    
}


@end
