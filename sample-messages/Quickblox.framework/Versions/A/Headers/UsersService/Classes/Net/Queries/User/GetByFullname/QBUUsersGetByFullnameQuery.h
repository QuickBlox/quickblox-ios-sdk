//
//  QBUUsersGetByFullnameQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUsersGetByFullnameQuery : QBUUserQuery{
}
@property (nonatomic, retain) NSString *userFullName;
@property (nonatomic, retain) PagedRequest *pagedRequest;

- (id)initWithUserFullName:(NSString *)_userFullName;
- (id)initWithUserFullName:(NSString *)_userFullName pagedRequest:(PagedRequest *)_pagedRequest;

@end
