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

@end
