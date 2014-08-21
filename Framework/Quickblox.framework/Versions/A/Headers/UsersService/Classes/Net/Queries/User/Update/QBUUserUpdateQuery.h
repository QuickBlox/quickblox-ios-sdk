//
//  QBUUserUpdateQuery.h
//  UsersService
//
//  Created by Macbook Injoit on 12/12/11.
//  Copyright (c) 2011 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUserUpdateQuery : QBUUserQuery{
}
@property (nonatomic,retain) QBUUser *user;

- (id)initWithUser:(QBUUser *)tuser;

@end