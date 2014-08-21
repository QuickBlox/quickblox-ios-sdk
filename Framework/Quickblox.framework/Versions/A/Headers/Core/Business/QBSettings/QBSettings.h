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

/**
 Set TURN server domain
 
 @param turnDomain New TURN server domain
 */
+ (void)setTURNServerDomain:(NSString *)turnDomain;

/**
 Get TURN server domain
 
 @return Current TURN server domain
 */
+ (NSString *)TURNServerDomain;

/**
 Set Content bucket
 
 @param bucket New bucket name
 */
+ (void)setContentBucket:(NSString *)bucket;

/**
 Get Content bucket
 
 @return Current bucket
 */
+ (NSString *)contentBucket;


#pragma mark -
#pragma mark HTTPS

/**
 Enable/disable HTTPS for queries
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* No need to call this method, HTTPS set by default now
 
 @param useHTTPS Enable HTTPS for queries. Default value: YES.
 */
+ (void)useHTTPS:(BOOL)useHTTPS __attribute__((deprecated("No need to call this method, HTTPS set by default now")));

/**
 Current protocol to perform queries to QuickBlox
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* No need to call this method, HTTPS set by default now
 
 @return YES if HTTPS is enabled;
 */
+ (BOOL)isUseHTTPS __attribute__((deprecated("No need to call this method, HTTPS set by default now")));


#pragma mark -
#pragma mark TLS for Chat

/**
 Enable/disable TLS for chat
 
 @param useTLSForChat Enable TLS for chat. Default value: YES.
 */
+ (void)useTLSForChat:(BOOL)useTLSForChat;

/**
 Current protocol to work with Chat
 
 @return YES if TLS is enabled;
 */
+ (BOOL)isUseTLSForChat;


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
