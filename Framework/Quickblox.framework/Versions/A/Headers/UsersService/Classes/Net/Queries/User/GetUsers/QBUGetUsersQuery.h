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
@property (nonatomic, retain) NSString *ids;
@property (nonatomic, retain) NSArray *logins;
@property (nonatomic, retain) NSArray *emails;
@property (nonatomic, retain) NSArray *phoneNumbers;
@property (nonatomic, retain) NSArray *facebookIDs;
@property (nonatomic, retain) NSArray *twitterIDs;

-(id)initWithRequest:(PagedRequest *)_pagedRequest;

@end
