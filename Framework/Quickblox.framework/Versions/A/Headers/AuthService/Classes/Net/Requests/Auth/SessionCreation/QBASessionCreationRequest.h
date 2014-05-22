//
//  QBASessionCreationRequest.h
//  AuthService
//
//  Created by Igor Khomenko on 3/13/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBASessionCreationRequest class declaration. */
/** Overview */
/** This class represent an instance of request for session creation - extended set of request parameters. */

@interface QBASessionCreationRequest : Request{
}

/** Social network provider. Posible values: facebook, twitter */
@property(nonatomic, retain) NSString *socialProvider;

/** Permissions for choosen social provider */
@property(nonatomic, retain) NSArray *scope;

/** Social network provider's access token */
@property(nonatomic, retain) NSString *socialProviderAccessToken;

/** Social network provider's access token secret (need only for Twitter) */
@property(nonatomic, retain) NSString *socialProviderAccessTokenSecret;

/** QBUUser login. */
@property(nonatomic, retain) NSString *userLogin;

/** QBUUser email. */
@property(nonatomic, retain) NSString *userEmail;

/** QBUUser password. */
@property(nonatomic, retain) NSString *userPassword;

@end
