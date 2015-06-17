//
//  QBUUser.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"

/** QBUUser class declaration. */
/** Overview */
/** This class represents QuickBlox User. */

@interface QBUUser : QBCEntity <NSCoding, NSCopying> {
@private
    NSUInteger externalUserID;
    NSInteger blobID;
    NSString *facebookID;
    NSString *twitterID;
    NSString *fullName;
    NSString *email;
    NSString *login;
    NSString *phone;
    NSString *website;
    NSMutableArray *tags;
    NSString *password;
    NSString *oldPassword;
    NSDate *lastRequestAt;
    NSString *customData;
}

/** ID of User in external system. */
@property (nonatomic) NSUInteger externalUserID;

/** ID of User associated blob (for example, ID of user's photo). */
@property (nonatomic) NSInteger blobID;

/** ID of User in Facebook. */
@property (nonatomic, retain) NSString *facebookID;

/** ID of User in Twitter. */
@property (nonatomic, retain) NSString *twitterID;

/** User's full name. */
@property (nonatomic, retain) NSString *fullName;

/** User's email. */
@property (nonatomic, retain) NSString *email;

/** User's login. */
@property (nonatomic, retain) NSString *login;

/** User's phone. */
@property (nonatomic, retain) NSString *phone;

/** User's website. */
@property (nonatomic, retain) NSString *website;

/** User's tags. */
@property (nonatomic, retain) NSMutableArray *tags;

/** User's password. */
@property (nonatomic, retain) NSString *password;

/** User's old password. */
@property (nonatomic, retain) NSString *oldPassword;

/** User's last activity */
@property (nonatomic, retain) NSDate *lastRequestAt;

/** User's custom data field */
@property (nonatomic, retain) NSString *customData;

/** Create new user
 @return New instance of QBUUser
 */
+ (QBUUser *)user;
@end