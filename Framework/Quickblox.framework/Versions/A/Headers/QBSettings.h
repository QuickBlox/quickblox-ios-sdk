//
//  QBSettings.h
//  Core
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBLogger.h"

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
+ (void)setApplicationID:(NSUInteger)applicationID __deprecated_msg("Use [QBApplication sharedApplication].applicationId instead");

/**
 Get application ID
 
 @return Current application ID
 */
+ (NSUInteger)applicationID __deprecated_msg("Use [QBApplication sharedApplication].applicationId instead");

/**
 Set authorization key. This key is created at the time of adding a new application to your Account through the web interface. You can not set it yourself. You should use this key in your API Application to get access to QuickBlox through the API interface.
 
 @param authorizationKey Application key - from admin.quickblox.com
 */
+ (void)setAuthorizationKey:(NSString *)authorizationKey __deprecated_msg("Use [QBConnection registerServiceKey:serviceKey]  instead");

/**
 Get authorization key
 
 @return Current authorization key
 */
+ (NSString *)authorizationKey;

/**
 Set authorization secret. Secret sequence which is used to prove Authentication Key. It's similar to a password. You have to keep it private and restrict access to it. Use it in your API Application to create your signature for authentication request.
 
 @param authorizationSecret Authorization secret - from admin.quickblox.com
 */
+ (void)setAuthorizationSecret:(NSString *)authorizationSecret __deprecated_msg("Use [QBConnection registerServiceSecret:serviceSecret] instead");

/**
 Get authorization secret
 
 @return Current authorization secret
 */
+ (NSString *)authorizationSecret;

/**
 Set account key
 
 @param accountKey Account key - from admin.quickblox.com
 */
+ (void)setAccountKey:(NSString *)accountKey;

/**
 Get account key
 
 @return Current account key
 */
+ (NSString *)accountKey;


#pragma mark -
#pragma mark Endpoints

/**
 Set server's Chat domain
 
 @param chatDomain New server's Chat domain
 */
+ (void)setServerChatDomain:(NSString *)chatDomain;

/**
 Get server's Chat domain
 
 @return Current server's Chat domain
 */
+ (NSString *)serverChatDomain;

/**
 *  MUC chat server domain
 *
 *  @return Current server's MUC chat domain
 */
+ (NSString *)chatServerMUCDomain;

/**
 Set Content bucket

 @warning Deprecated in 2.3. No need to use this method anymore.
 
 @param bucket New bucket name
 */
+ (void)setContentBucket:(NSString *)bucket __attribute__((deprecated("No need to use this method anymore.")));

/**
 Get Content bucket
 
 @warning Deprecated in 2.3. No need to use this method anymore.
 
 @return Current bucket
 */
+ (NSString *)contentBucket __attribute__((deprecated("No need to use this method anymore.")));


#pragma mark -
#pragma mark HTTPS

/**
 Enable/disable HTTPS for queries
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* No need to call this method, HTTPS is set by default now
 
 @param useHTTPS Enable HTTPS for queries. Default value: YES.
 */
+ (void)useHTTPS:(BOOL)useHTTPS __attribute__((deprecated("No need to call this method, HTTPS is set by default now")));

/**
 Current protocol to perform queries to QuickBlox
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* No need to call this method, HTTPS is set by default now
 
 @return YES if HTTPS is enabled;
 */
+ (BOOL)isUseHTTPS __attribute__((deprecated("No need to call this method, HTTPS  is set by default now")));


#pragma mark -
#pragma mark TLS for Chat

/**
 Enable/disable TLS for chat
 
 @warning *Deprecated in QB iOS SDK 2.3:* No need to call this method, TLS is set to YES by default now
 
 @param useTLSForChat Enable TLS for chat. Default value: NO.
 */
+ (void)useTLSForChat:(BOOL)useTLSForChat __attribute__((deprecated("No need to call this method, TLS is set to YES by default now")));

/**
 Current protocol to work with Chat
 
 @warning *Deprecated in QB iOS SDK 2.3:* No need to call this method, TLS is set to YES by default now
 
 @return YES if TLS is enabled;
 */
+ (BOOL)isUseTLSForChat __attribute__((deprecated("No need to call this method, TLS is set to YES by default now")));


#pragma mark -
#pragma mark Chat proxy

/**
 Set Chat SOCKS5 proxy host
 
 @param host SOCKS5 proxy host
 */
+ (void)setChatSOCKS5ProxyHost:(NSString *)host;

/**
 Get сhat SOCKS5 proxy host
 
 @return Current сhat SOCKS5 proxy host
 */
+ (NSString *)chatSOCKS5ProxyHost;

/**
 Set Chat SOCKS5 proxy port
 
 @param port SOCKS5 proxy port
 */
+ (void)setChatSOCKS5ProxyPort:(NSUInteger)port;

/**
 Get сhat SOCKS5 proxy port
 
 @return Current сhat SOCKS5 proxy port
 */
+ (NSUInteger)chatSOCKS5ProxyPort;


#pragma mark -
#pragma mark Logging

/**
 Set SDK log level (by default: QBLogLevelDebug). Posible values: QBLogLevelDebug, QBLogLevelNothing.
 
 @param logLevel New log level
 */
+ (void)setLogLevel:(QBLogLevel)logLevel;

/**
 Get SDK log level
 
 @return SDK current log level
 */
+ (QBLogLevel)logLevel;

/**
 *  Enables XMPP Framework logging to console. By default is disabled.
 */
+ (void)enableXMPPLogging;

/**
 *   Disables XMPP Framework logging to console.
 */
+ (void)disableXMPPLogging;

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
+ (void)setRestAPIVersion:(NSString *)restAPIVersion __deprecated_msg("Use [QBApplication sharedApplication].restAPIVersion instead");

/**
 Get REST API Version.
 
 @return Current REST API Version.
 */
+ (NSString *)restAPIVersion __deprecated_msg("Use [QBApplication sharedApplication].restAPIVersion instead");


#pragma mark -
#pragma mark Session expiration handler

/**
 Enable session expiration auto handler
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* Use [QBBaseModule sharedModule].tokenExpirationDate to get session expiration date and recreate a session if need
 
 @param isEnable New session expiration auto handler's state
 */
+ (void)enableSessionExpirationAutoHandler:(BOOL)isEnable __attribute__((deprecated("Use [QBBaseModule sharedModule].tokenExpirationDate to get session expiration date and recreate a session if need")));

/**
 Get session expiration auto handler's state
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* Use [QBBaseModule sharedModule].tokenExpirationDate to get session expiration date and recreate a session if need
 
 @return Current session expiration auto handler's state
 */
+ (BOOL)isEnabledSessionExpirationAutoHandler __attribute__((deprecated("Use [QBBaseModule sharedModule].tokenExpirationDate to get session expiration date and recreate a session if need")));


#pragma mark -
#pragma mark Push Notifications

/**
 Enable production environment for Push Notifications
 
 @param useProductionEnvironment Enable production environment for Push Notifications. Default value: NO. 
 */
+ (void)useProductionEnvironmentForPushNotifications:(BOOL)useProductionEnvironment __attribute__((deprecated("Use [QBApplication sharedApplication].productionEnvironmentForPushesEnabled instead")));

/**
 Determine current environment for Push Notifications
 
 @return YES if we use Production environment for Push Notifications
 */
+ (BOOL)isUseProductionEnvironmentForPushNotifications __attribute__((deprecated("Use [QBApplication sharedApplication].productionEnvironmentForPushesEnabled instead")));

@end
