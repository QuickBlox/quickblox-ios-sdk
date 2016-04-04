//
//  STKApiClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//Api credentials
extern NSString *const STKApiVersion;
extern NSString *const STKBaseApiUrl;

//

@class AFHTTPSessionManager;

@interface STKApiAbstractService : NSObject

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) AFHTTPSessionManager *getSessionManager;


@end
