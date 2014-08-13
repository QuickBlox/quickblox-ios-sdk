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

    @return An instance of QBRequest for cancel operation mainly.
*/
+ (QBRequest *)createSessionWithSuccessBlock:(void (^)(QBResponse *response, QBASession *session))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
    Session Creation with extended Request

    Type of Result - QBAAuthSessionCreationResult.

    @param extendedParameters Extended set of request parameters
    @return An instance of QBRequest for cancel operation mainly.
*/
+ (QBRequest *)createSessionWithExtendedParameters:(QBSessionParameters *)extendedParameters successBlock:(void (^)(QBResponse *response, QBASession *session))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
    Session Destroy

    Type of Result - QBAAuthResult.

    @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
*/
+ (QBRequest *)destroySessionWithSuccessBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - LogIn

/**
* User LogIn with login
*
* @param login Login of QBUUser which authenticates.
* @param password Password of QBUUser which authenticates.
* @param successBlock An callback. Will return QBUserSessionInformation class if request is successful.
* @return An instance of QBRequest for cancel operation mainly.
*/
+ (QBRequest *)logInWithUserLogin:(NSString *)login password:(NSString *)password successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 User LogIn with email

 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithUserEmail:(NSString *)email password:(NSString *)password successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


/**
 User LogIn with social provider

 @param provider Social provider. Posible values: facebook, twitter.
 @param scope Permission. Permissions for choosen provider. Should not be nil.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithSocialProvider:(NSString *)provider scope:(NSArray *)scope successBlock:(void (^)(QBResponse *response, QBUUser* user))successBlock errorBlock:(void (^)(QBResponse *response))errorBlock;

/**
 User LogIn with social provider's token

 @param provider Social provider. Posible values: facebook, twitter.
 @param accessToken Social provider access token.
 @param accessTokenSecret Social provider access token secret.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithSocialProvider:(NSString *)provider accessToken:(NSString *)accessToken
                     accessTokenSecret:(NSString *)accessTokenSecret successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
                            errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark -  LogOut

/**
 User LogOut

 Type of Result - QBUUserLogOutResult

 @param successBlock An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserLogoutResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)logOutWithSuccessBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Create User

/**
 User sign up
 
 @param successBlock Block with response and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)signUp:(QBUUser *)user successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
		   errorBlock:(void (^)(QBResponse *response))errorBlock;

@end