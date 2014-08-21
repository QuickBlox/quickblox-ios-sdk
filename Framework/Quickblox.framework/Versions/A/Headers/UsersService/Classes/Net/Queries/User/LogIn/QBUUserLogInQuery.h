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

// social API properties
@property (nonatomic, retain) NSString *socialProvider;
@property (nonatomic, retain) NSArray *socialProviderScope;
@property (nonatomic, retain) NSString *socialProviderAccessToken;
@property (nonatomic, retain) NSString *socialProviderAccessTokenSecret;

- (id)initWithQBUUser:(QBUUser *)user;
- (id)initWithSocialProvider:(NSString *)socialProvider andScope:(NSArray *)scope;
- (id)initWithSocialProvider:(NSString *)socialProvider accessToken:(NSString *)accessToken accessTokenSecret:(NSString *)accessTokenSecret;

@end