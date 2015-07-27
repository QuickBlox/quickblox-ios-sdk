//
//  STKApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"
#import <AFNetworking.h>
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"

NSString *const STKApiVersion = @"v1";
NSString *const STKBaseApiUrl = @"http://api.stickerpipe.com/api";

@implementation STKApiAbstractService

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *baseUrl = [NSString stringWithFormat:@"%@/%@", STKBaseApiUrl, STKApiVersion];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        [serializer setValue:STKApiVersion forHTTPHeaderField:@"ApiVersion"];
        [serializer setValue:@"iOS" forHTTPHeaderField:@"Platform"];
        [serializer setValue:[STKUUIDManager generatedDeviceToken] forHTTPHeaderField:@"DeviceId"];
        [serializer setValue:[STKApiKeyManager apiKey] forHTTPHeaderField:@"ApiKey"];
        [serializer setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"Package"];
        
        self.sessionManager.requestSerializer = serializer;
    }
    return self;
}

@end
