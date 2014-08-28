//
//  SSUUserCache.m
//  SimpleSample-users-ios
//
//  Created by Andrey Moskvin on 7/21/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "SSUUserCache.h"

@implementation SSUUserCache

+ (instancetype)instance
{
    static SSUUserCache* cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [SSUUserCache new];
    });
    return cache;
}

- (void)saveUser:(QBUUser *)user
{
    _currentUser = user;
}

@end
