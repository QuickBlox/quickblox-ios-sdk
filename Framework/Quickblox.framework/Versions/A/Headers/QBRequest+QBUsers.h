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
+ (QBRequest *)usersWithSuccessBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						  errorBlock:(void (^)(QBResponse *response))errorBlock;

/**
 Retrieve all Users for current account (with extended set of pagination parameters)

 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersForPage:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
				 errorBlock:(void (^)(QBResponse *response))errorBlock;

/**
 Retrieve all Users for current account with extended request
 
 @param extendedRequest Dictionary with extended request
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithExtendedRequest:(NSDictionary *)extendedRequest
                                   page:(QBGeneralResponsePage *)responsePage
                           successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
                             errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get User with ID

/**
 Retrieve User by identifier

 @param userID ID of QBUUser to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithID:(NSUInteger)userID successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
			   errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users with IDs

/**
 Retrieve users with ids (with extended set of pagination parameters)
 
 @param IDs IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithIDs:(NSArray *)IDs page:(QBGeneralResponsePage *)page
			   successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
				 errorBlock:(void (^)(QBResponse *))errorBlock;

#pragma mark - Get User with login

/**
 Retrieve User by login

 @param userLogin Login of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithLogin:(NSString *)userLogin successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
				  errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users with Logins

/**
 Retrieve users with logins (max 10 users)

 @param logins Logins of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithLogins:(NSArray *)logins successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve users with logins (with extended set of pagination parameters)

 @param logins Logins of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithLogins:(NSArray *)logins page:(QBGeneralResponsePage *)page
				  successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users with full name

/**
 Retrieve Users by full name for current account (last 10 users)

 @param userFullName Full name of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFullName:(NSString *)userFullName successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					  errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)

 @param userFullName Full name of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFullName:(NSString *)userFullName page:(QBGeneralResponsePage *)page
					successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					  errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users with tags

/**
 Retrieve Users by tags for current account (last 10 users)

 @param tags Tags of users to be retrieved.
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTags:(NSArray *)tags successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
				  errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve Users by tags for current account (with extended set of pagination parameters)

 @param tags Tags of users to be retrieved.
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTags:(NSArray *)tags page:(QBGeneralResponsePage *)page
				successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
				  errorBlock:(void (^)(QBResponse *response))errorBlock;
#pragma mark - Get Users with phone numbers

/**
 Retrieve users with phone numbers (max 10 users)

 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)usersWithPhoneNumbers:(NSArray *)phoneNumbers successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						  errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve users with phone numbers (with extended set of pagination parameters)

 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithPhoneNumbers:(NSArray *)phoneNumbers page:(QBGeneralResponsePage *)page
						successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						  errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get User with Facebook ID

/**
 Retrieve User by Facebook ID

 @param userFacebookID Facebook ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithFacebookID:(NSString *)userFacebookID successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
					   errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users Facebook IDs

/**
 Retrieve users with facebook ids (max 10 users)

 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFacebookIDs:(NSArray *)facebookIDs successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						 errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve users with facebook ids (with extended set of pagination parameters)

 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithFacebookIDs:(NSArray *)facebookIDs page:(QBGeneralResponsePage *)page
					   successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						 errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get User with Twitter ID

/**
 Retrieve User by Twitter ID

 @param userTwitterID Twitter ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithTwitterID:(NSString *)userTwitterID successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
					  errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users Twitter IDs

/**
 Retrieve users with twitter ids (max 10 users)

 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTwitterIDs:(NSArray *)twitterIDs successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						errorBlock:(void (^)(QBResponse *response))errorBlock;
/**
 Retrieve users with twitter ids (with extended set of pagination parameters)

 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithTwitterIDs:(NSArray *)twitterIDs page:(QBGeneralResponsePage *)page
					  successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
						errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get User with email

/**
 Retrieve User by Email

 @param userEmail Email of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithEmail:(NSString *)userEmail successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
				  errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get Users with emails

/**
 Retrieve users with email (max 10 users)

 @param emails Emails of users which you want to retrieve
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithEmails:(NSArray *)emails successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					errorBlock:(void (^)(QBResponse *response))errorBlock;

/**
 Retrieve users with email (with extended set of pagination parameters)

 @param emails Emails of users which you want to retrieve
 @param page Pagination parameters
 @param successBlock Block with response, page and users instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)usersWithEmails:(NSArray *)emails page:(QBGeneralResponsePage *)page
				  successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))successBlock
					errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Get User with external ID

/**
 Retrieve User by External identifier

 @param userExternalID External ID of user to be retrieved.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)userWithExternalID:(NSUInteger)userExternalID successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
					   errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Update User

/**
 Update User

 @warning Deprecated in QB iOS SDK 2.3. Use 'updateCurrentUser:successBlock:errorBlock:' instead.
 
 @param user An instance of QBUUser, describing the user to be edited.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateUser:(QBUUser *)user successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
			   errorBlock:(void (^)(QBResponse *response))errorBlock  __attribute__((deprecated("Use updateCurrentUser:successBlock:errorBlock: instead")));


/**
 Update current session user.
 
 @param parameters   User parameters that could be updated.
 @param successBlock Block with response and user instances if request succeded.
 @param errorBlock   Block with response instance if request failed.
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateCurrentUser:(QBUpdateUserParameters *)parameters successBlock:(void (^)(QBResponse *response, QBUUser *user))successBlock
                      errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Delete User

/**
 Delete User by identifier

 @param userID ID of user to be removed.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteUserWithID:(NSUInteger)userID successBlock:(void (^)(QBResponse *response))successBlock
					 errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Delete User with external ID

/**
 Delete User by external identifier

 @param userExternalID External ID of user to be removed.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteUserWithExternalID:(NSUInteger)userExternalID successBlock:(void (^)(QBResponse *response))successBlock
							 errorBlock:(void (^)(QBResponse *response))errorBlock;

#pragma mark - Reset password

/**
 Reset user's password. User with this email will retrieve an email instruction for reset password.

 @param email User's email
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)resetUserPasswordWithEmail:(NSString *)email successBlock:(void (^)(QBResponse *response))successBlock
							   errorBlock:(void (^)(QBResponse *response))errorBlock;

@end
