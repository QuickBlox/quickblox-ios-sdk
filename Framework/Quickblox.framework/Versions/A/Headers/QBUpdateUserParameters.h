//
//  QBUpdateUserParameters.h
//  Quickblox
//
//  Created by Andrey Moskvin on 5/25/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUpdateUserParameters : NSObject

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

/** User's custom data field */
@property (nonatomic, retain) NSString *customData;

@end
