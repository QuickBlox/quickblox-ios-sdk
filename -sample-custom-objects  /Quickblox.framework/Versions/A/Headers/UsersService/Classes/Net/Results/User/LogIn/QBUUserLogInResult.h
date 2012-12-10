//
//  QBUUserLogInResult.h
//  UsersService
//
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBUUserLogInResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after Sign In. */

@interface QBUUserLogInResult : QBUUserResult {

}

/** Social provider access token .*/
@property (nonatomic, readonly) NSString *socialProviderToken;

/** Social provider access token expiration date .*/
@property (nonatomic, readonly) NSDate *socialProviderTokenExpiresAt;

@end
