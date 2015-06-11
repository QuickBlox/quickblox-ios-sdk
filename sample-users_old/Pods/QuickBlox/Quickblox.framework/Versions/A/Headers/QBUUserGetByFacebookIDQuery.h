//
//  QBUUserGetByFacebookIDQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBUUserQuery.h"

@interface QBUUserGetByFacebookIDQuery : QBUUserQuery{
}
@property (nonatomic, retain) NSString *userFacebookID;

- (id)initWithUserFacebookID:(NSString *)userFacebookID;

@end