//
//  UsersDataSource.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 06/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "MainDataSource.h"

@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface UsersDataSource : MainDataSource<QBUUser *>

+ (instancetype)usersDataSource;

- (nullable QBUUser *)userWithID:(NSUInteger)ID;

@end

NS_ASSUME_NONNULL_END
