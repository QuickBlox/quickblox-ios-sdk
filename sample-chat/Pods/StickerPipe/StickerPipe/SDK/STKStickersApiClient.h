//
//  STKStickersApiClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiClient.h"

@interface STKStickersApiClient : STKApiClient

- (void)getStickersPackWithType:(NSString*)type success:(void (^)(id response))success
                        failure:(void (^)(NSError *error))failure;

@end
