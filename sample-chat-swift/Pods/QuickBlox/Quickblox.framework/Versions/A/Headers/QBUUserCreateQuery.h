//
//  QBUUserCreateQuery.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBUUserQuery.h"

@class QBUUser;


@interface QBUUserCreateQuery : QBUUserQuery {
}
@property (nonatomic,retain) QBUUser *user;

- (id)initWithUser:(QBUUser *)_user;

@end
