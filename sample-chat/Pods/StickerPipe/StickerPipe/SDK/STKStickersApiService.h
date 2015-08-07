//
//  STKStickersApiClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"

@interface STKStickersApiService : STKApiAbstractService

- (void)getStickersPackWithType:(NSString*)type success:(void (^)(id response, NSTimeInterval lastModifiedDate))success
                        failure:(void (^)(NSError *error))failure;

@end
