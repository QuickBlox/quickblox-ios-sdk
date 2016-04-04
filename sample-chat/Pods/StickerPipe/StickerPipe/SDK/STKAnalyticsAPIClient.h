//
//  STKAnalyticsAPIClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"
@interface STKAnalyticsAPIClient : STKApiAbstractService

- (void) sendStatistics:(NSArray*)statisticsArray
             success:(void(^)(id response))success
                failure:(void(^)(NSError *error))failure;

@end
