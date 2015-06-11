//
//  QBSessionParameters.h
//  Quickblox
//
//  Created by Andrey Kozlov on 18/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

@interface QBSessionParameters : NSObject

/// Social network provider. Posible values: facebook, twitter
@property(nonatomic, retain) NSString *socialProvider;

/// Permissions for choosen social provider
@property(nonatomic, retain) NSArray *scope;

/// Social network provider's access token
@property(nonatomic, retain) NSString *socialProviderAccessToken;

/// Social network provider's access token secret (need only for Twitter)
@property(nonatomic, retain) NSString *socialProviderAccessTokenSecret;

/// QBUUser login.
@property(nonatomic, retain) NSString *userLogin;

/// QBUUser email.
@property(nonatomic, retain) NSString *userEmail;

/// QBUUser password.
@property(nonatomic, retain) NSString *userPassword;

@end
