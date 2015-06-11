//
//  QBAAuthSessionCreationResult.h
//  AuthService
//
//  Created by Igor Khomenko on 2/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBAAuthResult.h"

@class QBASession;

/** QBAAuthSessionCreationResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for session creation. */

@interface QBAAuthSessionCreationResult : QBAAuthResult{
    
}

/** An instance of QBASession.*/
@property (nonatomic, readonly) QBASession *session;

/** Unique auto generated sequence of numbers which identify API User as the legitimate user of our system. It is used in relatively short periods of time and can be easily changed. We grant API Users some rights after authentication and check them based on this token. */
@property (nonatomic, readonly) NSString *token;

/** Social provider access token .*/
@property (nonatomic, readonly) NSString *socialProviderToken;

/** Social provider access token expiration date .*/
@property (nonatomic, readonly) NSDate *socialProviderTokenExpiresAt;

@end
