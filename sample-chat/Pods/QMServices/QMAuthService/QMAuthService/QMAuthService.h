//
//  QMBaseAuthService.h
//  QMServices
//
//  Created by Andrey Ivanov on 29.10.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

@protocol QMAuthServiceDelegate;

@interface QMAuthService : QMBaseService

/**
 *  Identifies user authorisation status.
 */
@property (assign, nonatomic, readonly) BOOL isAuthorized;

/**
 *  Add instance that confirms auth service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMAuthServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMAuthServiceDelegate>)delegate;

/**
 *  Remove instance that confirms auth service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMAuthServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMAuthServiceDelegate>)delegate;

/**
 *  User sign up and login
 *
 *  @param user       QuickBlox User
 *  @param completion completion block
 *
 *  @return Canceble request
 */
- (QBRequest *)signUpAndLoginWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

/**
 *  User login
 *
 *  @param user       QuickBlox User
 *  @param completion completion block
 *
 *  @return Canceble request
 */
- (QBRequest *)logInWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

/**
 *  Login with facebook
 *
 *  @param sessionToken Facebook session token
 *  @param completion   Completion block
 *
 *  @return Canceble request
 */
- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

/**
 *  Logout
 *
 *  @param completion completion block
 *
 *  @return Cancable request
 */
- (QBRequest *)logOut:(void(^)(QBResponse *response))completion;

@end

@protocol QMAuthServiceDelegate <NSObject>
@optional

/**
 *  It called when auth service did log out
 *
 *  @param authService QMAuthService instance
 */
- (void)authServiceDidLogOut:(QMAuthService *)authService;

/**
 *  It called when auth service did log in with user
 *
 *  @param authService QMAuthService instance
 *  @param user logined QBUUser
 */
- (void)authService:(QMAuthService *)authService didLoginWithUser:(QBUUser *)user;

@end
