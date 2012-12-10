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

@end
