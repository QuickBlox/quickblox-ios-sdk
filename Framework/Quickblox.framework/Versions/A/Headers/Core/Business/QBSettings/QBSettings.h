//
//  QBSettings.h
//  Core
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBSettings class declaration */
/** Overview */
/** Class for setup framework */

@interface QBSettings : NSObject {
}

#pragma mark -
#pragma mark Credentials

/**
 Set application ID

 @param applicationID Application ID - from admin.quickblox.com
 */
+ (void)setApplicationID:(NSUInteger)applicationID;

/**
 Get application ID
 
 @return Current application ID
 */
+ (NSUInteger)applicationID;

/**
 Set authorization key. This key is created at the time of adding a new application to your Account through the web interface. You can not set it yourself. You should use this key in your API Application to get access to QuickBlox through the API interface.
 
 @param authorizationKey Application key - from admin.quickblox.com
 */
+ (void)setAuthorizationKey:(NSString *)authorizationKey;

/**
 Get authorization key
 
 @return Current authorization key
 */
+ (NSString *)authorizationKey;

/**
 Set authorization secret. Secret sequence which is used to prove Authentication Key. It's similar to a password. You have to keep it private and restrict access to it. Use it in your API Application to create your signature for authentication request.
 
 @param authorizationSecret Authorization secret - from admin.quickblox.com
 */
+ (void)setAuthorizationSecret:(NSString *)authorizationSecret;

/**
 Get authorization secret
 
 @return Current authorization secret
 */
+ (NSString *)authorizationSecret;


#pragma mark -
#pragma mark Server domain

/**
 Set server's domain (by default: quickblox.com)
 
 @param domain New server's domain
 */
+ (void)setServerDomain:(NSString *)domain;

/**
 Get server's domain
 
 @return Current server's domain
 */
+ (NSString *)serverDomain;


#pragma mark -
#pragma mark Hardcoded Server domains

/**
 Set server's API domain
 
 @param apiDomain New server's API domain
 */
+ (void)setServerApiDomain:(NSString *)apiDomain;

/**
 Get server's API domain
 
 @return Current server's API domain
 */
+ (NSString *)serverApiDomain;

/**
 Set server's Chat domain
 
 @param apiDomain New server's Chat domain
 */
+ (void)setServerChatDomain:(NSString *)chatDomain;

/**
 Get server's Chat domain
 
 @return Current server's Chat domain
 */
+ (NSString *)serverChatDomain;


#pragma mark -
#pragma mark Server zone

/**
 Set server's zone (by default: QBServerZoneProduction). Posible values: QBServerZoneProduction -> api.quickblox.com, QBServerZoneStage -> api.stage.quickblox.com
 
 @param zone New server's zone
 */
+ (void)setServerZone:(enum QBServerZone)zone;

/**
 Get server's zone
 
 @return Current server's zone
 */
+ (enum QBServerZone)serverZone;

+ (NSString *)serverZoneAsString;


#pragma mark -
#pragma mark HTTPS

/**
 Enable/disable HTTPS for queries
 
 @param useHTTPS Enable HTTPS for queries. Default value: NO. 
 */
+ (void)useHTTPS:(BOOL)useHTTPS;

/**
 Current protocol to perform queries to QuickBlox
 
 @return YES if HTTPS is enabled;
 */
+ (BOOL)isUseHTTPS;


#pragma mark -
#pragma mark Logging

/**
 Set SDK log level (by default: QBLogLevelDebug). Posible values: QBLogLevelDebug, QBLogLevelNothing.
 
 @param logLevel New log level
 */
+ (void)setLogLevel:(enum QBLogLevel)logLevel;

/**
 Get SDK log level
 
 @return SDK current log level
 */
+ (enum QBLogLevel)logLevel;


#pragma mark -
#pragma mark Timeout

/**
 Set request timeout
 
 @param timeOutseconds timeout in seconds
 */

+ (void)setTimeOutSeconds:(int)timeOutseconds;

/**
 Get request timeout.
 
 @return Request timeout in seconds
 */
+ (int)timeOutSeconds;


#pragma mark -
#pragma mark REST-API-Version

/**
 Set REST API Version.
 
 @param restAPIVersion New REST API Version
 */
+ (void)setRestAPIVersion:(NSString *)restAPIVersion;

/**
 Get REST API Version.
 
 @return Current REST API Version.
 */
+ (NSString *)restAPIVersion;


#pragma mark -
#pragma mark Session expiration handler

/**
 Enable session expiration auto handler
 
 @param isEnable New session expiration auto handler's state
 */
+ (void)enableSessionExpirationAutoHandler:(BOOL)isEnable;

/**
 Get session expiration auto handler's state
 
 @return Current session expiration auto handler's state
 */
+ (BOOL)isEnabledSessionExpirationAutoHandler;


#pragma mark -
#pragma mark Push Notifications

/**
 Enable production environment for Push Notifications
 
 @param useProductionEnvironment Enable production environment for Push Notifications. Default value: NO. 
 */
+ (void)useProductionEnvironmentForPushNotifications:(BOOL)useProductionEnvironment;

/**
 Determine current environment for Push Notifications
 
 @return YES if we use Production environment for Push Notifications
 */
+ (BOOL)isUseProductionEnvironmentForPushNotifications;


#pragma mark -
#pragma mark Video Chat

/**
 Set Video Chat configuration
 
 @param configuration New configuration
 */
+ (void)setVideoChatConfiguration:(NSDictionary *)configuration;

/**
 Get Video Chat configuration
 
 @return Video Chat current configuration
 */
+ (NSDictionary *)videoChatConfiguration;

@end
