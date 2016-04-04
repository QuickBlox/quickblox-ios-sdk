
//
//  STKStickersApiClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersApiService.h"
#import <AFNetworking/AFNetworking.h>
#import "STKUUIDManager.h"
#import "STKApiKeyManager.h"
#import "STKStickersManager.h"
#import "STKUtility.h"


static NSString *const packsURL = @"shop/my";



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


- (void)getStickersPacksForUserWithSuccess:(void (^)(id response, NSTimeInterval lastModifiedDate))success
                                   failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{@"is_subscriber": @([STKStickersManager isSubscriber])};
    
    [self.getSessionManager GET:packsURL parameters: params
                        success:^(NSURLSessionDataTask *task, id responseObject) {
                            
                            NSTimeInterval timeInterval = 0;
                            
                            timeInterval = [responseObject[@"meta"][@"shop_last_modified"] doubleValue];
                            
                            if ([responseObject[@"data"] count] == 0) {
                                STKLog(@"get empty stickers pack JSON");
                            }
                            
                            if (success) {
                                success(responseObject, timeInterval);
                            }
                        }
                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                            if (failure) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    failure(error);
                                });
                            }
                        }];
    
}

- (void)getStickersPackWithType:(NSString*)type
                        success:(void (^)(id response, NSTimeInterval lastModifiedDate))success
                        failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = nil;
    if (type) {
        parameters = @{@"type" : type};
    }
    
    [self.sessionManager GET:packsURL parameters:parameters
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
                         if (failure) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 failure(error);
                             });
                         }
                     }];
}


- (void)getStickerPackWithName:(NSString *)packName
                       success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure
{
    NSString *route = [NSString stringWithFormat:@"pack/%@", packName];
    
    [self.sessionManager GET:route parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getStickerInfoWithId:(NSString *)contentId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *))failure {
    
    NSString *route = [NSString stringWithFormat:@"content/%@", contentId];
    
    
    [self.sessionManager GET:route parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (void)loadStickerPackWithName:(NSString *)packName andPricePoint:(NSString *)pricePoint
                        success:(void (^)(id))success
                        failure:(void (^)(NSError *))failure
{
    NSString *route = [NSString stringWithFormat:@"packs/%@", packName];
    NSDictionary *params = @{@"purchase_type": [self purchaseType:pricePoint]};
    
    [self.sessionManager POST:route parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)purchaseType:(NSString *)pricePoint {
    if ([pricePoint isEqualToString:@"A"]) {
        return @"free";
    } else if ([pricePoint isEqualToString:@"B"]) {
        return ([STKStickersManager isSubscriber]) ? @"subscription" : @"oneoff";
    } else if ([pricePoint isEqualToString:@"C"]) {
        return @"oneoff";
    }
    return @"";
}

- (void)deleteStickerPackWithName:(NSString *)packName
                          success:(void (^)(id))success
                          failure:(void (^)(NSError *))failure
{
    NSString *route = [NSString stringWithFormat:@"packs/%@", packName];
    
    [self.sessionManager DELETE:route parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end
