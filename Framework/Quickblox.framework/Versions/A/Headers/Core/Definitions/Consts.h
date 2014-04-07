/*
 *  Consts.h
 *  BaseService
 *
 *
 */

#define N(V) (V==nil)?@"":V
#define S(S,...) [NSString stringWithFormat:S,__VA_ARGS__]

#define quickbloxStandartServerUrl @"quickblox.com"

#define QBToken @"Qb-Token"

#define qbhttp @"http"
#define qbhttps @"https"

extern NSString* const kBaseServiceErrorDomain;
extern NSString* const kBaseServiceErrorKeyDescription;
extern NSString* const kBaseServiceErrorKeyInner;
extern NSString* const kBaseServiceException;

//Errors
extern NSString* const kBaseServiceErrorTimeout;
extern NSString* const kBaseServiceErrorNotFound;
extern NSString* const kBaseServiceErrorValidation;
extern NSString* const kBaseServiceErrorBadRequest;
extern NSString* const kBaseServiceErrorUnauthorized;
extern NSString* const kBaseServiceErrorUnexpectedStatus;
extern NSString* const kBaseServiceErrorUnexpectedContentType;
extern NSString* const kBaseServiceErrorUnknownContentType;
extern NSString* const kBaseServiceErrorInternalError;
extern NSString* const kBaseServiceErrorSocialCredentialsNotFound;

//Exceptions
extern NSString* const kBaseServiceExceptionMissedAuthorization;
extern NSString* const kBaseServiceExceptionMissedCredentials;

//Service Names
extern NSString* const QuickbloxServiceChat;

// Social
extern NSString* const QuickbloxSocialAuthTwitterCallback;
extern NSString* const QuickbloxSocialAuthFacebookCallback;
extern NSString* const QuickbloxSocialAuthFailure;

// Notifications
extern NSString* const QuickbloxSocialDialogDidCloseNotification;

#define kBaseServiceDateNotSet [NSDate dateWithTimeIntervalSince1970:0] 
#define kBaseServiceObjectNotSet nil
#define kBaseServiceIDNotSet 0
#define kBaseServiceStringNotSet [NSString string]
#define kBaseServiceBoolNotSet FALSE
#define kBaseServiceValueNotSet 0

#define kBaseServicePageNotSet 0
#define kBaseServicePerPageNotSet 0

// log
#define QBDLog(...) if([QBSettings logLevel] == QBLogLevelDebug) [AsyncLogger LogF:[NSString stringWithFormat:__VA_ARGS__]] 

#define QBDLogEx(...) if([QBSettings logLevel] == QBLogLevelDebug) [AsyncLogger LogF:[NSString stringWithFormat:@"%s -> %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]]] 

#define E(A,B,C) @throw [NSException exceptionWithName:A reason:B userInfo:C];
#define E2(A,B) @throw [NSException exceptionWithName:A reason:B userInfo:nil];
#define EB(B,C) E(kBaseServiceException, B,C)
#define EB2(B) E2(kBaseServiceException, B)

#define QB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)