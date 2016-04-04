//
//  STKApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"
#import <AFNetworking/AFNetworking.h>
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"
#import "STKStickersManager.h"
#import "STKStickersConstants.h"
#import "NSString+MD5.h"


NSString *const STKApiVersion = @"v2";
NSString *const STKBaseApiUrl = @"https://api.stickerpipe.com/api";
//NSString *const STKBaseApiUrl = @"http://work.stk.908.vc/api";

@implementation STKApiAbstractService

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *baseUrl = [NSString stringWithFormat:@"%@/%@", STKBaseApiUrl, STKApiVersion];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        self.getSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        self.sessionManager.requestSerializer = [self baseSerializer];
        
        self.getSessionManager.requestSerializer = [self getSerializer];
    }
    return self;
}

- (AFJSONRequestSerializer *)baseSerializer {
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:[STKStickersManager userKey] forHTTPHeaderField:@"UserID"];
    [serializer setValue:STKApiVersion forHTTPHeaderField:@"ApiVersion"];
    [serializer setValue:@"iOS" forHTTPHeaderField:@"Platform"];
    [serializer setValue:[STKUUIDManager generatedDeviceToken] forHTTPHeaderField:@"DeviceId"];
    [serializer setValue:[STKApiKeyManager apiKey] forHTTPHeaderField:@"ApiKey"];
    [serializer setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"Package"];
    [serializer setValue:[self localization] forHTTPHeaderField:@"Localization"];
    
    return serializer;
}

- (AFJSONRequestSerializer *)getSerializer {
    AFJSONRequestSerializer *serializer = [self baseSerializer];
    NSNumber *isSubscriber = [NSNumber numberWithBool:[STKStickersManager isSubscriber]];
    [serializer setValue:[isSubscriber stringValue] forHTTPHeaderField:@"is_subscriber"];
    
    return serializer;
}

- (NSString *)localization {
    NSString *locale = [[NSUserDefaults standardUserDefaults]
                        stringForKey:kLocalizationDefaultsKey];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return (locale) ? locale : language;
}

@end
