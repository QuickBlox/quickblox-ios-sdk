//
//  QBSessionParameters.h
//  Quickblox
//
//  Created by Andrey Kozlov on 18/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBSessionParameters : NSObject <NSCoding>

/// Social network provider. Posible values: facebook, twitter
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *socialProvider;

/// Permissions for choosen social provider
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSString *) *scope;

/// Social network provider's access token
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *socialProviderAccessToken;

/// Social network provider's access token secret (need only for Twitter)
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *socialProviderAccessTokenSecret;

/// QBUUser login.
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *userLogin;

/// QBUUser email.
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *userEmail;

/// QBUUser password.
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *userPassword;

@end
