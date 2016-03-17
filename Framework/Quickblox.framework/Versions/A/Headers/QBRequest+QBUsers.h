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

@interface QBRequest (QBUsers)

#pragma mark - Get all Users for current account

/**
 Retrieve all Users for current account (last 10 users)

 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                     errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Retrieve all Users for current account (with extended set of pagination parameters)

 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersForPage:(QB_NULLABLE QBGeneralResponsePage *)page
                          successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                            errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Retrieve all Users for current account with extended request
 
 @param extendedRequest Dictionary with extended request
 @param responsePage Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithExtendedRequest:(QB_NONNULL NSDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                                              page:(QB_NULLABLE QBGeneralResponsePage *)responsePage
                                      successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                        errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with ID

/**
 Retrieve User by identifier

 @param userID ID of QBUUser to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithID:(NSUInteger)userID successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                          errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users with IDs

/**
 Retrieve users with ids (with extended set of pagination parameters)
 
 @param IDs IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)IDs
                                  page:(QB_NULLABLE QBGeneralResponsePage *)page
                          successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                            errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with login

/**
 Retrieve User by login

 @param userLogin Login of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithLogin:(QB_NONNULL NSString *)userLogin
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                             errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users with Logins

/**
 Retrieve users with logins (max 10 users)

 @param logins Logins of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithLogins:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)logins
                             successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                               errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve users with logins (with extended set of pagination parameters)

 @param logins Logins of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithLogins:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)logins
                                     page:(QB_NULLABLE QBGeneralResponsePage *)page
                             successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                               errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users with full name

/**
 Retrieve Users by full name for current account (last 10 users)

 @param userFullName Full name of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithFullName:(QB_NONNULL NSString *)userFullName
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                 errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)

 @param userFullName Full name of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithFullName:(QB_NONNULL NSString *)userFullName
                                       page:(QB_NULLABLE QBGeneralResponsePage *)page
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                 errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users with tags

/**
 Retrieve Users by tags for current account (last 10 users)

 @param tags Tags of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithTags:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)tags
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                             errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve Users by tags for current account (with extended set of pagination parameters)

 @param tags Tags of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithTags:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)tags
                                   page:(QB_NULLABLE QBGeneralResponsePage *)page
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                             errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
#pragma mark - Get Users with phone numbers

/**
 Retrieve users with phone numbers (max 10 users)

 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QB_NONNULL QBRequest *)usersWithPhoneNumbers:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)phoneNumbers
                                   successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                     errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve users with phone numbers (with extended set of pagination parameters)

 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithPhoneNumbers:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)phoneNumbers
                                           page:(QB_NULLABLE QBGeneralResponsePage *)page
                                   successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                     errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with Facebook ID

/**
 Retrieve User by Facebook ID

 @param userFacebookID Facebook ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithFacebookID:(QB_NONNULL NSString *)userFacebookID
                                successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                  errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users Facebook IDs

/**
 Retrieve users with facebook ids (max 10 users)
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithFacebookIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)facebookIDs
                                  successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                    errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve users with facebook ids (with extended set of pagination parameters)
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithFacebookIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)facebookIDs
                                          page:(QB_NULLABLE QBGeneralResponsePage *)page
                                  successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                    errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with Twitter ID

/**
 Retrieve User by Twitter ID
 
 @param userTwitterID Twitter ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithTwitterID:(QB_NONNULL NSString *)userTwitterID
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                 errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users Twitter IDs

/**
 Retrieve users with twitter ids (max 10 users)
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithTwitterIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)twitterIDs
                                 successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                   errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;
/**
 Retrieve users with twitter ids (with extended set of pagination parameters)
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithTwitterIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)twitterIDs
                                         page:(QB_NULLABLE QBGeneralResponsePage *)page
                                 successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                                   errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with email

/**
 Retrieve User by Email
 
 @param userEmail Email of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithEmail:(QB_NONNULL NSString *)userEmail
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                             errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get Users with emails

/**
 Retrieve users with email (max 10 users)
 
 @param emails Emails of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithEmails:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)emails
                             successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                               errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

/**
 Retrieve users with email (with extended set of pagination parameters)
 
 @param emails Emails of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)usersWithEmails:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)emails
                                     page:(QB_NULLABLE QBGeneralResponsePage *)page
                             successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBUUser *) * QB_NULLABLE_S users))successBlock
                               errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Get User with external ID

/**
 Retrieve User by External identifier
 
 @param userExternalID External ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)userWithExternalID:(NSUInteger)userExternalID
                                successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                  errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Update User

/**
 Update current session user.
 
 @param parameters   User parameters that could be updated.
 @param successBlock Block with response and user instances if request succeded.
 @param errorBlock   Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateCurrentUser:(QB_NONNULL QBUpdateUserParameters *)parameters
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBUUser * QB_NULLABLE_S user))successBlock
                                 errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Delete Current User

/**
 Delete Current User
 
 @note You should login firstly in order to delete current user
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteCurrentUserWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
												 errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

#pragma mark - Reset password

/**
 Reset user's password. User with this email will retrieve an email instruction for reset password.
 
 @param email User's email
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)resetUserPasswordWithEmail:(QB_NONNULL NSString *)email
                                        successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                          errorBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))errorBlock;

@end
