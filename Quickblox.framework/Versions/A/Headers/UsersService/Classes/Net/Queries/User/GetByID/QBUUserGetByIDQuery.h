//
//  QBUUserGetByIDQuery.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBUUserGetByIDQuery : QBUUserQuery {
}
@property (nonatomic) NSUInteger userID;

- (id)initWithUserID:(NSUInteger)userID;

@end
