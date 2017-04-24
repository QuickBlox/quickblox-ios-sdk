//
// Created by QuickBlox team on 14/12/2013.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequest.h"

@class QBResponse;
@class QBASession;
@class QBSessionParameters;
@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

typedef void(^qb_response_user_block_t)(QBResponse *response, QBUUser *user);

@interface QBRequest (QBAuth)

//MARK: - App authorization

/**
 Session Destroy
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)destroySessionWithSuccessBlock:(nullable qb_response_block_t)successBlock
                                   errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - LogIn

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
                     successBlock:(nullable qb_response_user_block_t)successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

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
                     successBlock:(nullable qb_response_user_block_t)successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

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
                           accessToken:(nullable NSString *)accessToken
                     accessTokenSecret:(nullable NSString *)accessTokenSecret
                          successBlock:(nullable qb_response_user_block_t)successBlock
                            errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 *  User login using Twitter Digits.
 *
 *  @param headers      Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'.
 *  @param successBlock Block with response and user instances if request succeded.
 *  @param errorBlock   Block with response instance if request failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithTwitterDigitsAuthHeaders:(NSDictionary *)headers
                                    successBlock:(nullable qb_response_user_block_t)successBlock
                                      errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - LogOut

/**
 LogOut current user
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logOutWithSuccessBlock:(nullable qb_response_block_t)successBlock
                           errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Create User

/**
 User sign up
 
 @param user User to signup
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)signUp:(QBUUser *)user
         successBlock:(nullable qb_response_user_block_t)successBlock
           errorBlock:(nullable qb_response_block_t)errorBlock;

@end

NS_ASSUME_NONNULL_END
