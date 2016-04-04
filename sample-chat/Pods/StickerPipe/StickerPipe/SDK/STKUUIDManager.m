//
//  STKUDIDManager.m
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKUUIDManager.h"

static NSString *const kUDIDKey = @"kUDIDKey";


@implementation STKUUIDManager

+ (NSString *)generatedDeviceToken {
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [defaults stringForKey:kUDIDKey];
    
    if (!key) {
        NSUUID *uuid = [NSUUID UUID];
        key = uuid.UUIDString;
        [defaults setObject:key forKey:kUDIDKey];
    }
    return key;
}

@end
