//
//  StorageManager.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

/**
 *  Stores users.
 */
@property (copy, nonatomic) NSArray *users;

- (instancetype)init __attribute__ ((unavailable("-init is not supported initializer")));
+ (instancetype)instance;

/**
 *  Returns user with given ID from in-memory storage.
 *
 *  @param userID User identifier.
 *
 *  @return QBUUser instance.
 */
- (QBUUser *)userByID:(NSUInteger)identifier;

@end
