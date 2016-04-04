//
//  STKStickersApiClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"

@interface STKStickersApiService : STKApiAbstractService

- (void)getStickersPacksForUserWithSuccess:(void (^)(id response, NSTimeInterval lastModifiedDate))success
                 failure:(void (^)(NSError *error))failure;

- (void)getStickerPackWithName:(NSString*)packName
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *error))failure;

- (void)getStickerInfoWithId:(NSString *)contentId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *))failure;


- (void)loadStickerPackWithName:(NSString *)packName andPricePoint:(NSString *)pricePoint
                        success:(void (^)(id))success
                        failure:(void (^)(NSError *))failure;

- (void)deleteStickerPackWithName:(NSString *)packName
                          success:(void (^)(id))success
                          failure:(void (^)(NSError *))failure;

@end
