//
//  QBSessionParameters.h
//  Quickblox
//
//  Created by Andrey Kozlov on 18/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

@interface QBSessionParameters : NSObject <NSCoding>

/// Social network provider. Posible values: facebook, twitter
@property(nonatomic, strong) NSString *socialProvider;

/// Permissions for choosen social provider
@property(nonatomic, strong) NSArray *scope;

/// Social network provider's access token
@property(nonatomic, strong) NSString *socialProviderAccessToken;

/// Social network provider's access token secret (need only for Twitter)
@property(nonatomic, strong) NSString *socialProviderAccessTokenSecret;

/// QBUUser login.
@property(nonatomic, strong) NSString *userLogin;

/// QBUUser email.
@property(nonatomic, strong) NSString *userEmail;

/// QBUUser password.
@property(nonatomic, strong) NSString *userPassword;

@end
