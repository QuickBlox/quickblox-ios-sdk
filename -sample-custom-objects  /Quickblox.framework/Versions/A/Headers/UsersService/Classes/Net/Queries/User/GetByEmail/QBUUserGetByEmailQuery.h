//
//  QBUUserGetByEmailQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUserGetByEmailQuery : QBUUserQuery{
}
@property (nonatomic, retain) NSString *userEmail;

- (id)initWithUserEmail:(NSString *)userEmail;

@end
