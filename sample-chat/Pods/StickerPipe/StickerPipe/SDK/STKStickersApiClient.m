//
//  STKStickersApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersApiClient.h"
#import <AFNetworking.h>
#import "STKStickersMapper.h"
#import "STKUUIDManager.h"
#import "STKApiKeyManager.h"
#import "STKUtility.h"

@interface STKStickersApiClient()

@property (strong, nonatomic) STKStickersMapper *mapper;
@property (strong, nonatomic) dispatch_queue_t completionQueue;

@end

@implementation STKStickersApiClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mapper = [[STKStickersMapper alloc] init];
        
        self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        self.sessionManager.completionQueue = self.completionQueue;

        
//        self.sessionManager.requestSerializer = serializer;
    }
    return self;
}

- (void)getStickersPackWithType:(NSString*)type
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = nil;
    if (type) {
        parameters = @{@"type" : type};
    }

    
    __weak typeof(self) weakSelf = self;
    
    [self.sessionManager GET:@"client-packs" parameters:parameters
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         
                         [weakSelf.mapper mappingStickerPacks:responseObject[@"data"] async:NO];
                         
                         if ([responseObject[@"data"] count] == 0) {
                             STKLog(@"get empty stickers pack JSON");
                         }
                         
                         if (success) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 success(responseObject);
                             });
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
