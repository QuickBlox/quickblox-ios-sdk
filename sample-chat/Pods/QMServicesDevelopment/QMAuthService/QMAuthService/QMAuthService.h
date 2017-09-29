//
//  QMBaseAuthService.h
//  QMServices
//
//  Created by Andrey Ivanov on 29.10.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

@protocol QMAuthServiceDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QMAuthService : QMBaseService

/// Identifies user authorisation status.
@property (assign, nonatomic, readonly) BOOL isAuthorized;

/**
 Add instance that confirms auth service multicaste protocol
 
 @param delegate instance that confirms id<QMAuthServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMAuthServiceDelegate>)delegate;

/**
 Remove instance that confirms auth service multicaste protocol
 
 @param delegate instance that confirms id<QMAuthServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMAuthServiceDelegate>)delegate;

/**
 User sign up and login
 
 @param user QuickBlox User
 @param completion completion block
 @return Cancelable request
 */

- (QBRequest *)signUpAndLoginWithUser:(QBUUser *)user
                           completion:(nullable void(^)(QBResponse *response, QBUUser * _Nullable userProfile))completion;

/**
 User login
 
 @param user QuickBlox User
 @param completion completion block
 @return Cancelable request
 */
- (QBRequest *)logInWithUser:(QBUUser *)user
                  completion:(nullable void(^)(QBResponse *response, QBUUser * _Nullable userProfile))completion;

/**
 Login with firebase project ID and accessToken
 
 @param projectID Firebase project ID
 @param accessToken Firebase access token
 @param completion ompletion block with response and user profile
 @return Cancelable request
 */
- (QBRequest *)logInWithFirebaseProjectID:(NSString *)projectID
                              accessToken:(NSString *)accessToken
                               completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

/**
 Login with facebook

 @param sessionToken Facebook session token
 @param completion completion block
 @return Cancelable request
 */
- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken
                                  completion:(nullable void(^)(QBResponse *response, QBUUser * _Nullable userProfile))completion;

/**
 Login with twitter
 
 @param accessToken Twitter access token
 @param accessTokenSecret Twitter access token secret
 @param completion completion block
 @return Cancelable request
 */

- (QBRequest *)loginWithTwitterAccessToken:(NSString *)accessToken accessTokenSecret:(NSString *)accessTokenSecret
                                completion:(nullable void(^)(QBResponse *response, QBUUser * _Nullable userProfile))completion;

/**
 Logout
 
 @param completion completion block
 @return Cancelable request
 */
- (QBRequest *)logOut:(nullable void(^)(QBResponse *response))completion;

@end

//MARK: - Bolts

/**
 Bolts methods for QMAuthService
 @see In order to know how to work with BFTask's see documentation
 https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
@interface QMAuthService (Bolts)

/**
 Sign up user and login using Bolts.
 
 @param user user instance to sign up and login
 @return BFTask with QBUUser instance or error
 */
- (BFTask<QBUUser *> *)signUpAndLoginWithUser:(QBUUser *)user;

/**
 Login with user using Bolts.
 
 @param user user instance to login
 @return BFTask with QBUUser instance or error
 */
- (BFTask<QBUUser *> *)loginWithUser:(QBUUser *)user;

/**
 Login with Firebase @see https://firebase.google.com/support/guides/digits-ios
 
 @param projectID Firebase project ID
 @param accessToken Firebase access tocken
 @return BFTask with QBUUser instance
 */
- (BFTask<QBUUser *> *)logInWithFirebaseProjectID:(NSString *)projectID
                                      accessToken:(NSString *)accessToken;

/**
 Login with facebook session token using Bolts.
 
 @param sessionToken valid facebook token with Email access
 @return BFTask with QBUUser instance or error
 */
- (BFTask<QBUUser *> *)loginWithFacebookSessionToken:(NSString *)sessionToken;

/**
 Login with twitter using Bolts.
 
 @param accessToken       twitter access token
 @param accessTokenSecret twitter access token secret
 @return BFTask with QBUUser instance or error
 */
- (BFTask<QBUUser *> *)loginWithTwitterAccessToken:(NSString *)accessToken
                                 accessTokenSecret:(NSString *)accessTokenSecret;

/**
 Logout current user using Bolts.
 
 @return BFTask with failure error
 */
- (BFTask *)logout;

@end

@protocol QMAuthServiceDelegate <NSObject>
@optional

/**
 It called when auth service did log out
 
 @param authService QMAuthService instance
 */
- (void)authServiceDidLogOut:(QMAuthService *)authService;

/**
 It called when auth service did log in with user
 
 @param authService QMAuthService instance
 @param user logined QBUUser
 */
- (void)authService:(QMAuthService *)authService didLoginWithUser:(QBUUser *)user;

@end

@interface QMAuthService(DEPRECATED)

/**
 Login with twitter digits auth headers
 
 @param authHeaders Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'
 @param completion  completion block with response and user profile
 @return Cancelable request
 */

- (QBRequest *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders
                                      completion:(nullable void(^)(QBResponse *response, QBUUser * _Nullable userProfile))completion
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.5 Use 'logInWithFirebaseProjectID:accessToken:successBlock:errorBlock:'.");


/**
 Login with twitter digits using Bolts.
 
 @param authHeaders Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'
 @return BFTask with QBUUser instance
 */
- (BFTask<QBUUser *> *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.5 Use 'logInWithFirebaseProjectID:accessToken:'.");

@end

NS_ASSUME_NONNULL_END
