//
//  QBUUserLogInQuery.h
//  UsersService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBUUserLogInQuery : QBUUserQuery {
}
@property (nonatomic, retain) QBUUser *user;
@property (nonatomic, retain) NSString *socialProvider;

- (id)initWithQBUUser:(QBUUser *)user;
- (id)initWithSocialProvider:(NSString *)socialProvider;

@end