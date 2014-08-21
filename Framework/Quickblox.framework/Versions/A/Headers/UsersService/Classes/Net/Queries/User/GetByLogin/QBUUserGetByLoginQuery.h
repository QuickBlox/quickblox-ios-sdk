//
//  QBUUserGetByLoginQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUserGetByLoginQuery : QBUUserQuery{
}
@property (nonatomic, retain) NSString *userLogin;

- (id)initWithUserLogin:(NSString *)userLogin;

@end
