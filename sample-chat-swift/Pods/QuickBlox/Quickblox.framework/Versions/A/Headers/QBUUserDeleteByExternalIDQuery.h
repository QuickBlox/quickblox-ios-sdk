//
//  QBUUserDeleteByExternalIDQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUserDeleteByExternalIDQuery : QBUUserQuery{
}
@property (nonatomic) NSUInteger externalUserID;

- (id)initWithExternalUserID:(NSUInteger)externalUserID;

@end
