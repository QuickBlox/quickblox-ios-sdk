//
//  QBUGetUsersQuery.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 YAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUGetUsersQuery : QBUUserQuery{
}
@property (nonatomic, retain) PagedRequest *pagedRequest;

-(id)initWithRequest:(PagedRequest *)_pagedRequest;

@end
