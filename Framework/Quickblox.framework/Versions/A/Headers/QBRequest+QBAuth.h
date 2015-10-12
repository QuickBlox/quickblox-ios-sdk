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

/**
 *  User login using Twitter Digits.
 *
 *  @param headers      Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'.
 *  @param successBlock Block with response and user instances if request succeded.
 *  @param errorBlock   Block with response instance if request failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)logInWithTwitterDigitsAuthHeaders:(QB_NONNULL NSDictionary *)headers
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