//
//  SSUUserCache.h
//  SimpleSample-users-ios
//
//  Created by Andrey Moskvin on 7/21/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUUserCache : NSObject

@property (nonatomic, readonly) QBUUser* currentUser;

+ (instancetype)instance;

- (void)saveUser:(QBUUser *)user;

@end
