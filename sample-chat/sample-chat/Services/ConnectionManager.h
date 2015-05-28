//
//  ConnectionManager.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/27/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "UsersDataSource.h"

@interface ConnectionManager : NSObject

@property (strong, nonatomic, readonly) UsersDataSource *usersDataSource;

+ (instancetype)instance;

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL success, NSString *errorMessage))completion;
- (void)logOut;

- (void)usersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

@end

@interface QBUUser (ConnectionManager)

- (NSUInteger)index;
- (UIColor *)color;

@end