//
//  QBRequest+QBUsers.h
//  Quickblox
//
//  Created by Andrey Kozlov on 09/12/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBResponse;
@class QBUUser;
@class QBGeneralResponsePage;
@class QBUpdateUserParameters;

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBUsers)

#pragma mark - Get all Users for current account

/**
 Retrieve all Users for current account (with extended set of pagination parameters)
 
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersForPage:(nullable QBGeneralResponsePage *)page
               successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                 errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 Retrieve all Users for current account with extended request
 
 @param extendedRequest Dictionary with extended request
 @param responsePage Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithExtendedRequest:(NSDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                                   page:(nullable QBGeneralResponsePage *)responsePage
                           successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                             errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with ID

/**
 Retrieve User by identifier
 
 @param userID ID of QBUUser to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithID:(NSUInteger)userID
             successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
               errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users with IDs

/**
 Retrieve users with ids (with extended set of pagination parameters)
 
 @param IDs IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithIDs:(NSArray QB_GENERIC(NSString *) *)IDs
                       page:(nullable QBGeneralResponsePage *)page
               successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                 errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with login

/**
 Retrieve User by login
 
 @param userLogin Login of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithLogin:(NSString *)userLogin
                successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users with Logins

/**
 Retrieve users with logins (with extended set of pagination parameters)
 
 @param logins Logins of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins
                          page:(nullable QBGeneralResponsePage *)page
                  successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                    errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users with full name

/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)
 
 @param userFullName Full name of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFullName:(NSString *)userFullName
                            page:(nullable QBGeneralResponsePage *)page
                    successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users with tags

/**
 Retrieve Users by tags for current account (with extended set of pagination parameters)
 
 @param tags Tags of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTags:(NSArray QB_GENERIC(NSString *) *)tags
                        page:(nullable QBGeneralResponsePage *)page
                successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;
#pragma mark - Get Users with phone numbers

/**
 Retrieve users with phone numbers (with extended set of pagination parameters)
 
 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithPhoneNumbers:(NSArray QB_GENERIC(NSString *) *)phoneNumbers
                                page:(nullable QBGeneralResponsePage *)page
                        successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                          errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with Facebook ID

/**
 Retrieve User by Facebook ID
 
 @param userFacebookID Facebook ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithFacebookID:(NSString *)userFacebookID
                     successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                       errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users Facebook IDs

/**
 Retrieve users with facebook ids (with extended set of pagination parameters)
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs
                               page:(nullable QBGeneralResponsePage *)page
                       successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                         errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with Twitter ID

/**
 Retrieve User by Twitter ID
 
 @param userTwitterID Twitter ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithTwitterID:(NSString *)userTwitterID
                    successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users Twitter IDs

/**
 Retrieve users with twitter ids (with extended set of pagination parameters)
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs
                              page:(nullable QBGeneralResponsePage *)page
                      successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                        errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with email

/**
 Retrieve User by Email
 
 @param userEmail Email of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithEmail:(NSString *)userEmail
                successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get Users with emails

/**
 Retrieve users with email (with extended set of pagination parameters)
 
 @param emails Emails of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails
                          page:(nullable QBGeneralResponsePage *)page
                  successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                    errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Get User with external ID

/**
 Retrieve User by External identifier
 
 @param userExternalID External ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithExternalID:(NSUInteger)userExternalID
                     successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                       errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Update User

/**
 Update current session user.
 
 @param parameters   User parameters that could be updated.
 @param successBlock Block with response and user instances if request succeded.
 @param errorBlock   Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateCurrentUser:(QBUpdateUserParameters *)parameters
                    successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Delete Current User

/**
 Delete Current User
 
 @note You should login firstly in order to delete current user
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteCurrentUserWithSuccessBlock:(nullable void (^)(QBResponse *response))successBlock
                                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - Reset password

/**
 Reset user's password. User with this email will retrieve an email instruction for reset password.
 
 @param email User's email
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)resetUserPasswordWithEmail:(NSString *)email
                             successBlock:(nullable void (^)(QBResponse *response))successBlock
                               errorBlock:(nullable QBRequestErrorBlock)errorBlock;

#pragma mark - DEPRECATE
/**
 Retrieve all Users for current account (last 10 users)
 
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithSuccessBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                          errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve users with email (max 10 users)
 
 @param emails Emails of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails
                  successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                    errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve users with logins (max 10 users)
 
 @param logins Logins of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins
                  successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                    errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve Users by full name for current account (last 10 users)
 
 @param userFullName Full name of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFullName:(NSString *)userFullName
                    successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                      errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve Users by tags for current account (last 10 users)
 
 @param tags Tags of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTags:(NSArray QB_GENERIC(NSString *) *)tags
                successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve users with phone numbers (max 10 users)
 
 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)usersWithPhoneNumbers:(NSArray QB_GENERIC(NSString *) *)phoneNumbers
                        successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                          errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve users with facebook ids (max 10 users)
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs
                       successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                         errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");

/**
 Retrieve users with twitter ids (max 10 users)
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs
                      successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray QB_GENERIC(QBUUser *) * _Nullable users))successBlock
                        errorBlock:(nullable QBRequestErrorBlock)errorBlock DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 This feature was removed.");
@end

NS_ASSUME_NONNULL_END
