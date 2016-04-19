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
- (void)addDelegate:(QB_NONNULL id <QMAuthServiceDelegate>)delegate;

/**
 *  Remove instance that confirms auth service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMAuthServiceDelegate> protocol
 */
- (void)removeDelegate:(QB_NONNULL id <QMAuthServiceDelegate>)delegate;

/**
 *  User sign up and login
 *
 *  @param user       QuickBlox User
 *  @param completion completion block
 *
 *  @return Cancelable request
 */
- (QB_NONNULL QBRequest *)signUpAndLoginWithUser:(QB_NONNULL QBUUser *)user completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBUUser *QB_NULLABLE_S userProfile))completion;

/**
 *  User login
 *
 *  @param user       QuickBlox User
 *  @param completion completion block
 *
 *  @return Cancelable request
 */
- (QB_NONNULL QBRequest *)logInWithUser:(QB_NONNULL QBUUser *)user completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBUUser *QB_NULLABLE_S userProfile))completion;

/**
 *  Login with twitter digits auth headers
 *
 *  @param authHeaders Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'
 *  @param completion  completion block with response and user profile
 *
 *  @return Cancelable request
 */
- (QB_NONNULL QBRequest *)loginWithTwitterDigitsAuthHeaders:(QB_NONNULL NSDictionary *)authHeaders completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBUUser *QB_NULLABLE_S userProfile))completion;

/**
 *  Login with facebook
 *
 *  @param sessionToken Facebook session token
 *  @param completion   completion block
 *
 *  @return Cancelable request
 */
- (QB_NONNULL QBRequest *)logInWithFacebookSessionToken:(QB_NONNULL NSString *)sessionToken completion:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response, QBUUser *QB_NULLABLE_S userProfile))completion;

/**
 *  Logout
 *
 *  @param completion completion block
 *
 *  @return Cancelable request
 */
- (QB_NONNULL QBRequest *)logOut:(void(^QB_NULLABLE_S)(QBResponse *QB_NONNULL_S response))completion;

@end

#pragma mark - Bolts

/**
 *  Bolts methods for QMAuthService
 */
@interface QMAuthService (Bolts)

/**
 *  Sign up user and login using Bolts.
 *
 *  @param user user instance to sign up and login
 *
 *  @return BFTask with QBUUser instance
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBUUser *) *)signUpAndLoginWithUser:(QB_NONNULL QBUUser *)user;

/**
 *  Login with user using Bolts.
 *
 *  @param user user instance to login
 *
 *  @return BFTask with QBUUser instance
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBUUser *) *)loginWithUser:(QB_NONNULL QBUUser *)user;

/**
 *  Login with twitter digits using Bolts.
 *
 *  @param authHeaders Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'
 *
 *  @return BFTask with QBUUser instance
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBUUser *) *)loginWithTwitterDigitsAuthHeaders:(QB_NONNULL NSDictionary *)authHeaders;

/**
 *  Login with facebook session token using Bolts.
 *
 *  @param sessionToken valid facebook token with Email access
 *
 *  @return BFTask with QBUUser instance
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask QB_GENERIC(QBUUser *) *)loginWithFacebookSessionToken:(QB_NONNULL NSString *)sessionToken;

/**
 *  Logout current user using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)logout;

@end

@protocol QMAuthServiceDelegate <NSObject>
@optional

/**
 *  It called when auth service did log out
 *
 *  @param authService QMAuthService instance
 */
- (void)authServiceDidLogOut:(QB_NONNULL QMAuthService *)authService;

/**
 *  It called when auth service did log in with user
 *
 *  @param authService QMAuthService instance
 *  @param user logined QBUUser
 */
- (void)authService:(QB_NONNULL QMAuthService *)authService didLoginWithUser:(QB_NONNULL QBUUser *)user;

@end
