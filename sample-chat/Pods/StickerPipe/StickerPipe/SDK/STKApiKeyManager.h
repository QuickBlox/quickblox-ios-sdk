//
//  STKApiKeyManager.h
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKApiKeyManager : NSObject

+ (void) setApiKey:(NSString*) apiKey;

+ (NSString*) apiKey;

@end
