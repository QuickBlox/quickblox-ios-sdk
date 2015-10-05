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

/** ID of User in external system. */
@property (nonatomic) NSUInteger externalUserID;

/** ID of User associated blob (for example, ID of user's photo). */
@property (nonatomic) NSInteger blobID;

/** ID of User in Facebook. */
@property (nonatomic, retain, QB_NULLABLE) NSString *facebookID;

/** ID of User in Twitter. */
@property (nonatomic, retain, QB_NULLABLE) NSString *twitterID;

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

/** User's custom data field */
@property (nonatomic, retain, QB_NULLABLE) NSString *customData;

@end
