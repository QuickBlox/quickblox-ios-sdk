//
//  STKStickersApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersApiService.h"
#import <AFNetworking.h>
#import "STKUUIDManager.h"
#import "STKApiKeyManager.h"
#import "STKUtility.h"

@implementation STKStickersApiService

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_queue_t completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        self.sessionManager.completionQueue = completionQueue;
    }
    return self;
}


- (void)getStickersPackWithType:(NSString*)type
                        success:(void (^)(id response, NSTimeInterval lastModifiedDate))success
                        failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = nil;
    if (type) {
        parameters = @{@"type" : type};
    }

    [self.sessionManager GET:@"client-packs" parameters:parameters
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         
                         NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[task response]);
                         NSTimeInterval timeInterval = 0;
                         if ([response respondsToSelector:@selector(allHeaderFields)]) {
                             NSDictionary *headers = [response allHeaderFields];
                            timeInterval = [headers[@"Last-Modified"] doubleValue];
                         }

                         if ([responseObject[@"data"] count] == 0) {
                             STKLog(@"get empty stickers pack JSON");
                         }
                         
                         if (success) {
                            success(responseObject, timeInterval);
                         }
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                 NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//                                 NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                         if (failure) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 failure(error);
                             });
                         }
                     }];
    
}

@end
