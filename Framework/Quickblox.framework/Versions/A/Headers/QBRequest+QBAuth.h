//
// Created by Andrey Kozlov on 14/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequest.h"

@class QBResponse;
@class QBASession;
@class QBSessionParameters;
@class QBUUser;

@interface QBRequest (QBAuth)

#pragma mark - App authorization

/**
 Session Creation
 
 @warning *Deprecated in QB iOS SDK 2.4.* Session is created and updated automatically by Quickblox SDK.
 
 @param successBlock Block with response and session instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createSessionWithSuccessBlock:(void (^)(QBResponse *response, QBASession *session))successBlock
                                  errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("Session is created and updated automatically by Quickblox SDK.")));

/**
 Session Creation with extended parameters
 
 @warning *Deprecated in QB iOS SDK 2.4.* Session is created and updated automatically by Quickblox SDK.
 
 @param extendedParameters Additional parameters to create a session
 @param successBlock Block with response and session instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createSessionWithExtendedParameters:(QBSessionParameters *)extendedParameters
                                      successBlock:(void (^)(QBResponse *response, QBASession *session))successBlock
                                        errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("Session is created and updated automatically by Quickblox SDK.")));

/**
 Session Destroy
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
*/
+ (QBRequest *)destroySessionWithSuccessBlock:(void (^)(QBResponse *response))successBlock
                                   errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - LogIn

/**
 User LogIn with login

 @param login Login of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithUserLogin:(NSString *)login
                         password:(NSString *)password
                     successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
                       errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 User LogIn with email

 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithUserEmail:(NSString *)email
                         password:(NSString *)password
                     successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
                       errorBlock:(QBRequestErrorBlock)errorBlock;


/**
 User LogIn with social provider
 
 @warning Deprecated in 2.4. Use '+[QBRequest logInWithSocialProvider:accessToken:accessTokenSecret:successBlock:errorBlock:' instead.' instead.

 @param provider Social provider. Posible values: facebook, twitter.
 @param scope Permission. Permissions for choosen provider. Should not be nil.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithSocialProvider:(NSString *)provider
                                 scope:(NSArray *)scope successBlock:(void (^)(QBResponse *response, QBUUser* user))successBlock
                            errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("use '+[QBRequest logInWithSocialProvider:accessToken:accessTokenSecret:successBlock:errorBlock:' instead.")));

/**
 User LogIn with social provider's token

 @param provider Social provider. Posible values: facebook, twitter.
 @param accessToken Social provider access token.
 @param accessTokenSecret Social provider access token secret.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithSocialProvider:(NSString *)provider
                           accessToken:(NSString *)accessToken
                     accessTokenSecret:(NSString *)accessTokenSecret
                          successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
                            errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -  LogOut

/**
 LogOut current user

 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logOutWithSuccessBlock:(void (^)(QBResponse *response))successBlock
                           errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Create User

/**
 User sign up
 
 @param user User to signup
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)signUp:(QBUUser *)user
         successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
		   errorBlock:(QBRequestErrorBlock)errorBlock;

@end