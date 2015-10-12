//
//  QBSettings.h
//  Core
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
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
+ (void)setAccountKey:(QB_NONNULL NSString *)accountKey;

/**
 Get account key
 
 @return Current account key
 */
+ (QB_NULLABLE NSString *)accountKey;


#pragma mark -
#pragma mark Endpoints

/**
 Set server's Chat domain
 
 @param chatDomain New server's Chat domain
 */
+ (void)setServerChatDomain:(QB_NONNULL NSString *)chatDomain;

/**
 Get server's Chat domain
 
 @return Current server's Chat domain
 */
+ (QB_NULLABLE NSString *)serverChatDomain;

/**
 *  MUC chat server domain
 *
 *  @return Current server's MUC chat domain
 */
+ (QB_NULLABLE NSString *)chatServerMUCDomain;

#pragma mark -
#pragma mark Chat proxy

/**
 Set Chat SOCKS5 proxy host
 
 @param host SOCKS5 proxy host
 */
+ (void)setChatSOCKS5ProxyHost:(QB_NONNULL NSString *)host;

/**
 Get сhat SOCKS5 proxy host
 
 @return Current сhat SOCKS5 proxy host
 */
+ (QB_NULLABLE NSString *)chatSOCKS5ProxyHost;

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
