//
//  QBUUser.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
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
@property (nonatomic, retain, QB_NULLABLE) NSString *facebookID;

/** ID of User in Twitter. */
@property (nonatomic, retain, QB_NULLABLE) NSString *twitterID;

/** ID of User in Twitter Digits. */
@property (nonatomic, retain, QB_NULLABLE) NSString *twitterDigitsID;

/** User's full name. */
@property (nonatomic, retain, QB_NULLABLE) NSString *fullName;

/** User's email. */
@property (nonatomic, retain, QB_NULLABLE) NSString *email;

/** User's login. */
@property (nonatomic, retain, QB_NULLABLE) NSString *login;

/** User's phone. */
@property (nonatomic, retain, QB_NULLABLE) NSString *phone;

/** User's website. */
@property (nonatomic, retain, QB_NULLABLE) NSString *website;

/** User's tags. */
@property (nonatomic, retain, QB_NULLABLE) NSMutableArray QB_GENERIC(NSString *) *tags;

/** User's password. */
@property (nonatomic, retain, QB_NULLABLE) NSString *password;

/** User's old password. */
@property (nonatomic, retain, QB_NULLABLE) NSString *oldPassword;

/** User's last activity */
@property (nonatomic, retain, QB_NULLABLE) NSDate *lastRequestAt;

/** User's custom data field */
@property (nonatomic, retain, QB_NULLABLE) NSString *customData;

/** Create new user
 @return New instance of QBUUser
 */
+ (QB_NONNULL QBUUser *)user;
@end