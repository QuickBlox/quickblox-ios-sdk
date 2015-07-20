//
//  STKApiKeyManager.m
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiKeyManager.h"

static NSString *savedApiKey;

@implementation STKApiKeyManager

+ (void)setApiKey:(NSString *)apiKey {
    NSAssert(apiKey != nil, @"No api key");
    NSAssert(apiKey.length > 0, @"No api key");
    savedApiKey = apiKey;
}

+ (NSString *)apiKey {
    NSAssert(savedApiKey != nil, @"No api key");
    NSAssert(savedApiKey.length > 0, @"No api key");
    return savedApiKey;
}

@end
