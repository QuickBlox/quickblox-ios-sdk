//
//  QBUUserDeleteByIDQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUserDeleteByIDQuery : QBUUserQuery{
}
@property (nonatomic) NSUInteger userID;

- (id)initWithUserID:(NSUInteger)userID;

@end
