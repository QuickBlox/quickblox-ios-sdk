//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Class is independent from SampleCoreManager
@interface LoginManager : NSObject

+ (void)loginOrSignupUser:(QBUUser *)user successBlock:(void(^)(QBResponse * response, QBUUser * _Nullable user))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

@end