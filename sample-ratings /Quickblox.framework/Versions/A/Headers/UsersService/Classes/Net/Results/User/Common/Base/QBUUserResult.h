//
//  QBUUserResult.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBUUserResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request to Users module. Represent a single user. */

@interface QBUUserResult : Result {

}

/** An instance of QBUUser.*/
@property (nonatomic, readonly) QBUUser *user;

@end