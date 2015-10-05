//
// Created by Andrey Kozlov on 14/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
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
+ (QB_NONNULL QBRequest *)createSessionWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBASession * QB_NULLABLE_S session))successBlock
                                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock __attribute__((deprecated("Session is created and updated automatically by Quickblox SDK.")));

/**
 Session Creation with extended parameters
 
 @warning *Deprecated in QB iOS SDK 2.4.* Session is created and updated automatically by Quickblox SDK.
 
 @param extendedParameters Additional parameters to create a session
 @param successBlock Block with response and session instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createSessionWithExtendedParameters:(QB_NULLABLE QBSessionParameters *)extendedParameters
                                                 successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBASession * QB_NULLABLE_S session))successBlock
                                                   errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock __attribute__((deprecated("Session is created and updated automatically by Quickblox SDK.")));

/**
 Session Destroy
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
*/
+ (QB_NONNULL QBRequest *)destroySessionWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                              errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - LogIn

/**
 User LogIn with login

 @param login Login of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logInWithUserLogin:(QB_NONNULL NSString *)login
                                    password:(QB_NONNULL NSString *)password
                                successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                  errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 User LogIn with email

 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logInWithUserEmail:(QB_NONNULL NSString *)email
                                    password:(QB_NONNULL NSString *)password
                                successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                  errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


/**
 User LogIn with social provider
 
 @warning Deprecated in 2.4. Use '+[QBRequest logInWithSocialProvider:accessToken:accessTokenSecret:successBlock:errorBlock:' instead.' instead.

 @param provider Social provider. Posible values: facebook, twitter.
 @param scope Permission. Permissions for choosen provider. Should not be nil.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logInWithSocialProvider:(QB_NONNULL NSString *)provider
                                            scope:(QB_NULLABLE NSArray QB_GENERIC(NSString *) *)scope
                                     successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                       errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock __attribute__((deprecated("use '+[QBRequest logInWithSocialProvider:accessToken:accessTokenSecret:successBlock:errorBlock:' instead.")));

/**
 User LogIn with social provider's token

 @param provider Social provider. Posible values: facebook, twitter.
 @param accessToken Social provider access token.
 @param accessTokenSecret Social provider access token secret.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logInWithSocialProvider:(QB_NONNULL NSString *)provider
                           accessToken:(QB_NULLABLE NSString *)accessToken
                     accessTokenSecret:(QB_NULLABLE NSString *)accessTokenSecret
                          successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark -  LogOut

/**
 LogOut current user

 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logOutWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                      errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Create User

/**
 User sign up
 
 @param user User to signup
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QB_NONNULL QBRequest *)signUp:(QB_NONNULL QBUUser *)user
                    successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                      errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

@end