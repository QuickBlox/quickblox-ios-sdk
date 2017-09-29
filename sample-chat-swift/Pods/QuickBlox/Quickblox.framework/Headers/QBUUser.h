//
//  QBUUser.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBUUser class interface.
 *  This class represents QuickBlox User.
 */
@interface QBUUser : QBCEntity <NSCoding, NSCopying>

/**
 *  ID of User in external system.
 */
@property (nonatomic, assign) NSUInteger externalUserID;

/** 
 *  ID of User associated blob (for example, ID of user's photo). 
 */
@property (nonatomic, assign) NSInteger blobID;

/** 
 *  ID of User in Facebook. 
 */
@property (nonatomic, copy, nullable) NSString *facebookID;

/** 
 *  ID of User in Twitter. 
 */
@property (nonatomic, copy, nullable) NSString *twitterID;

/** 
 *  ID of User in Twitter Digits.
 */
@property (nonatomic, copy, nullable) NSString *twitterDigitsID;

/** 
 *  User's full name. 
 */
@property (nonatomic, copy, nullable) NSString *fullName;

/** 
 *  User's email. 
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 *  User's login. 
 */
@property (nonatomic, copy, nullable) NSString *login;

/** 
 *  User's phone. 
 */
@property (nonatomic, copy, nullable) NSString *phone;

/** 
 *  User's website. 
 */
@property (nonatomic, copy, nullable) NSString *website;

/** 
 *  User's tags. 
 */
@property (nonatomic, strong, null_resettable) NSMutableArray<NSString *> *tags;

/** 
 *  User's password. 
 */
@property (nonatomic, copy, nullable) NSString *password;

/** 
 *  User's old password.
 */
@property (nonatomic, copy, nullable) NSString *oldPassword;

/**
 *  User's last activity.
 */
@property (nonatomic, strong, nullable) NSDate *lastRequestAt;

/** 
 *  User's custom data field.
 */
@property (nonatomic, copy, nullable) NSString *customData;

/** 
 *  Create new user.
 
 *  @return New instance of QBUUser
 */
+ (QBUUser *)user;

@end

NS_ASSUME_NONNULL_END
