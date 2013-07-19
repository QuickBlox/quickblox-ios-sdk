//
//  QBUsers.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBUsers class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Users module, user data and profiles management. */

@interface QBUsers : BaseService {

}

#pragma mark -
#pragma mark LogIn

/**
 User LogIn with login
 
 Type of Result - QBUUserLogInResult
 
 @param login Login of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserAuthenticateResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)logInWithUserLogin:(NSString *)login password:(NSString *)password delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)logInWithUserLogin:(NSString *)login password:(NSString *)password delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 User LogIn with email
 
 Type of Result - QBUUserLogInResult
 
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserAuthenticateResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)logInWithUserEmail:(NSString *)email password:(NSString *)password delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)logInWithUserEmail:(NSString *)email password:(NSString *)password delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 User LogIn with social provider
 
 Type of Result - QBUUserLogInResult
 
 @param provider Social provider. Posible values: facebook, twitter.
 @param scope Permission. Permissions for choosen provider.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserAuthenticateResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)logInWithSocialProvider:(NSString *)provider scope:(NSArray *)scope delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)logInWithSocialProvider:(NSString *)provider scope:(NSArray *)scope delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 User LogIn with social provider's token
 
 Type of Result - QBUUserLogInResult
 
 @param provider Social provider. Posible values: facebook, twitter.
 @param accessToken Social provider access token.
 @param accessTokenSecret Social provider access token secret.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserAuthenticateResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)logInWithSocialProvider:(NSString *)provider accessToken:(NSString *)accessToken accessTokenSecret:(NSString *)accessTokenSecret delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)logInWithSocialProvider:(NSString *)provider accessToken:(NSString *)accessToken accessTokenSecret:(NSString *)accessTokenSecret delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark LogOut

/**
 User LogOut
 
 Type of Result - QBUUserLogOutResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserLogoutResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)logOutWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)logOutWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get all Users for current account

/**
 Retrieve all Users for current account (last 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve all Users for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Create User

/**
 User sign up
 
 Type of Result - QBUUserResult
 
 @param user An instance of QBUUser, describing the user to be created.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)signUp:(QBUUser *)user delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)signUp:(QBUUser *)user delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with ID

/**
 Retrieve User by identifier
 
 Type of Result - QBUUserResult
 
 @param userID ID of QBUUser to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with IDs

/**
 Retrieve users with ids (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param ids IDs of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithIDs:(NSString *)ids delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithIDs:(NSString *)ids delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with ids (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param ids IDs of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithIDs:(NSString *)ids pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithIDs:(NSString *)ids pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with login

/**
 Retrieve User by login
 
 Type of Result - QBUUserResult
 
 @param userLogin Login of user to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithLogin:(NSString *)userLogin delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithLogin:(NSString *)userLogin delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with Logins

/**
 Retrieve users with logins (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param logins Logins of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithLogins:(NSArray *)logins delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithLogins:(NSArray *)logins delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with logins (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param logins Logins of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithLogins:(NSArray *)logins pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithLogins:(NSArray *)logins pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with full name

/**
 Retrieve Users by full name for current account (last 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 
 @param userFullName Full name of users to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithFullName:(NSString *)userFullName delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithFullName:(NSString *)userFullName delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param userFullName Full name of users to be retrieved.
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithFullName:(NSString *)userFullName pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithFullName:(NSString *)userFullName pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with tags

/**
 Retrieve Users by tags for current account (last 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 
 @param tags Tags of users to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithTags:(NSArray *)tags delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithTags:(NSArray *)tags delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve Users by tags for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param tags Tags of users to be retrieved.
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithTags:(NSArray *)tags pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithTags:(NSArray *)tags pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with phone numbers

/**
 Retrieve users with phone numbers (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithPhoneNumbers:(NSArray *)phoneNumbers delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithPhoneNumbers:(NSArray *)phoneNumbers delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with phone numbers (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param phoneNumbers Pnone numbers of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithPhoneNumbers:(NSArray *)phoneNumbers pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithPhoneNumbers:(NSArray *)phoneNumbers pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with Facebook ID

/**
 Retrieve User by Facebook ID
 
 Type of Result - QBUUserResult
 
 @param userFacebookID Facebook ID of user to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithFacebookID:(NSString *)userFacebookID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithFacebookID:(NSString *)userFacebookID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users Facebook IDs

/**
 Retrieve users with facebook ids (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithFacebookIDs:(NSArray *)facebookIDs delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithFacebookIDs:(NSArray *)facebookIDs delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with facebook ids (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithFacebookIDs:(NSArray *)facebookIDs pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithFacebookIDs:(NSArray *)facebookIDs pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with Twitter ID

/**
 Retrieve User by Twitter ID
 
 Type of Result - QBUUserResult
 
 @param userTwitterID Twitter ID of user to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithTwitterID:(NSString *)userTwitterID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithTwitterID:(NSString *)userTwitterID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users Twitter IDs

/**
 Retrieve users with twitter ids (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithTwitterIDs:(NSArray *)twitterIDs delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithTwitterIDs:(NSArray *)twitterIDs delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with twitter ids (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param twitterIDs Twitter IDs of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithTwitterIDs:(NSArray *)twitterIDs pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithTwitterIDs:(NSArray *)twitterIDs pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with email

/**
 Retrieve User by Email
 
 Type of Result - QBUUserResult
 
 @param userEmail Email of user to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithEmail:(NSString *)userEmail delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithEmail:(NSString *)userEmail delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Users with emails

/**
 Retrieve users with email (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param email Emails of users which you want to retrieve
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithEmails:(NSArray *)emails delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithEmails:(NSArray *)emails delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve users with email (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param email Emails of users which you want to retrieve
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)usersWithEmails:(NSArray *)emails pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)usersWithEmails:(NSArray *)emails pagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get User with external ID

/**
 Retrieve User by External identifier
 
 Type of Result - QBUUserResult
 
 @param userExternalID External ID of user to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)userWithExternalID:(NSUInteger)userExternalID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)userWithExternalID:(NSUInteger)userExternalID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update User

/**
 Update User
 
 Type of Result - QBUUserResult
 
 @param user An instance of QBUUser, describing the user to be edited.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateUser:(QBUUser *)user delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateUser:(QBUUser *)user delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete User

/**
 Delete User by identifier
 
 Type of Result - QBUUserResult
 
 @param userID ID of user to be removed.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteUserWithID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteUserWithID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete User with external ID

/**
 Delete User by external identifier
 
 Type of Result - QBUUserResult
 
 @param userExternalID External ID of user to be removed.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteUserWithExternalID:(NSUInteger)userExternalID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteUserWithExternalID:(NSUInteger)userExternalID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Reset password

/**
 Reset user's password. User with this email will retrieve email instruction for reset password.
 
 Type of Result - Result
 
 @param email User's email
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)resetUserPasswordWithEmail:(NSString *)email delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)resetUserPasswordWithEmail:(NSString *)email delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

@end