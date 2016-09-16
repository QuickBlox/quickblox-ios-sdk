//
//  QBUpdateUserParameters.h
//  Quickblox
//
//  Created by Andrey Moskvin on 5/25/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBUpdateUserParameters : NSObject

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
@property (nonatomic, strong, null_resettable) NSMutableArray QB_GENERIC(NSString *) *tags;

/** 
 *  User's password.
 */
@property (nonatomic, copy, nullable) NSString *password;

/** 
 *  User's old password. 
 */
@property (nonatomic, copy, nullable) NSString *oldPassword;

/** 
 *  User's custom data field.
 */
@property (nonatomic, copy, nullable) NSString *customData;

@end
