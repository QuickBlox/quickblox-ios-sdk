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

typedef enum QBConnectionZoneType{
	QBConnectionZoneTypeAutomatic = 1, //Default. Endpoints are loaded from QuickBlox
	QBConnectionZoneTypeProduction      = 2,
	QBConnectionZoneTypeDevelopment     = 3,
	QBConnectionZoneTypeStage           = 4
} QBConnectionZoneType;

/** QBSettings class declaration */
/** Overview */
/** Class for setup framework */

@interface QBSettings : NSObject

/**
 *  Allow to set api endpoint and chat endpoint for service zone.
 *
 *  @note QBConnectionZoneTypeAutomatic is used by default.
 *  If you are using shared server and you are migrating to enterprise account,
 *  then you don't need to resubmit your application, endpoints will be updated automatically.
 
 *  To set custom endpoints use QBConnectionZoneTypeProduction or QBConnectionZoneTypeDevelopment service zone.
 *  Then you should manually activate your service zone by calling setServiceZone:
 *
 *  @param apiEndpoint  apiEndpoint - Endpoint for service i.e. http://my_custom_endpoint.com. Possible to pass nil to return to default settings
 *  @param chatEndpoint chat endpoint
 *  @param zone         QBConnectionZoneType - service zone
 */
+ (void)setApiEndpoint:(QB_NULLABLE NSString *)apiEndpoint chatEndpoint:(QB_NULLABLE NSString *)chatEndpoint forServiceZone:(QBConnectionZoneType)zone;

#pragma mark -
#pragma mark Chat settings

/// Enable or disable chat auto reconnect
+ (void)setAutoReconnectEnabled:(BOOL)autoReconnectEnabled;

/* Background mode for stream. Not supported from 2.5.0 due to Apple policy on using battery in background mode.
 *
 * @warning *Deprecated in QB iOS SDK 2.5.0:* Method is no longer available.
 */
+ (void)setBackgroundingEnabled:(BOOL)backgroundingEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5.0. Method is no longer available.");

/// Enable or disable message carbons
+ (void)setCarbonsEnabled:(BOOL)carbonsEnabled;

/// Enable or disable Stream Resumption (XEP-0198).
+ (void)setStreamResumptionEnabled:(BOOL)streamResumptionEnabled;

/// Set timeout value for Stream Management send a message operation
+ (void)setStreamManagementSendMessageTimeout:(NSUInteger)streamManagementSendMessageTimeout;

/** A reconnect timer may optionally be used to attempt a reconnect periodically.
    Default value is 5 seconds */
+ (void)setReconnectTimerInterval:(NSTimeInterval)reconnectTimerInterval;

/**
 * Many routers will teardown a socket mapping if there is no activity on the socket.
 * For this reason, the stream supports sending keep-alive data.
 * This is simply whitespace, which is ignored by the protocol.
 *
 * Keep-alive data is only sent in the absence of any other data being sent/received.
 *
 * The default value is 20s.
 * The minimum value for TARGET_OS_IPHONE is 10s, else 20s.
 *
 * To disable keep-alive, set the interval to zero (or any non-positive number).
 *
 * The keep-alive timer (if enabled) fires every (keepAliveInterval / 4) seconds.
 * Upon firing it checks when data was last sent/received,
 * and sends keep-alive data if the elapsed time has exceeded the keepAliveInterval.
 * Thus the effective resolution of the keepalive timer is based on the interval.
 */
+ (void)setKeepAliveInterval:(NSTimeInterval)keepAliveInterval;

#pragma mark -
#pragma mark Credentials

/// Storing Application ID
+ (void)setApplicationID:(NSUInteger)applicationID;

/**
 Set account key
 
 @param accountKey Account key - from admin.quickblox.com
 */
+ (void)setAccountKey:(QB_NONNULL NSString *)accountKey;

/**
 * Setting API Key for Quickblox API
 *
 * @param authKey - NSString value of API Key.
 */
+ (void)setAuthKey:(QB_NONNULL NSString *)authKey;

/**
 * Setting API Secret for Quickblox API
 *
 * @param authSecret - NSString value of API Secret.
 */
+ (void)setAuthSecret:(QB_NONNULL NSString *)authSecret;

#pragma mark -
#pragma mark Endpoints

/**
 * Allow to change Services Zone to work with Development and Staging environments
 *
 * @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeAutomatic
 */
+ (void)setServiceZone:(QBConnectionZoneType)serviceZone;

/**
 *  Return current Service Zone
 *
 *  @note serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeAutomatic
 */
+ (QBConnectionZoneType)currentServiceZone;

/**
 *  Returns Api Endpoint for current zone
 *
 *  @return NSString value of Api Endpoint
 */
+ (QB_NULLABLE NSString *)apiEndpoint;

#pragma mark -
#pragma mark Chat Endpoints

/**
 *  Set server's Chat endpoint for current service zone
 *
 *  @param chatDomain New server's Chat endpoint
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'setApiEndpoint:chatEndpoint:forServiceZone:' instead.
 */
+ (void)setServerChatDomain:(QB_NONNULL NSString *)chatDomain DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use 'setApiEndpoint:chatEndpoint:forServiceZone:' instead");

/**
 Get server's Chat endpoint

 @note you have to prepend http or https prefix
 @return Current server's Chat endpoint
 */
+ (QB_NONNULL NSString *)chatEndpoint;
/* @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'chatEndpoint' instead. */
+ (QB_NONNULL NSString *)serverChatDomain DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use 'chatEndpoint' instead");

#pragma mark -
#pragma mark Network Indicator

/**
 * A Boolean value indicating whether the manager is enabled.
 
 * If YES, the manager will change status bar network activity indicator according to network operation notifications it receives. The default value is NO.
 */
+ (void)setNetworkIndicatorManagerEnabled:(BOOL)enabled;

/**
 A Boolean value indicating whether the network activity indicator is currently displayed in the status bar.
 */
+ (BOOL)isNetworkIndicatorVisible;

#pragma mark -
#pragma mark Logging

/**
 Set SDK log level (by default: QBLogLevelDebug). Posible values: QBLogLevelDebug, QBLogLevelNothing.
 
 @param logLevel New log level
 */
+ (void)setLogLevel:(QBLogLevel)logLevel;

/**
 *  Enables full XMPP Framework logging to console. By default is disabled.
 */
+ (void)enableXMPPLogging;

/**
 *   Disables full XMPP Framework logging to console.
 */
+ (void)disableXMPPLogging;

#pragma mark - 
#pragma mark NSURLSessionConfiguration

/**
 *  Set custom session configuration that will be used for REST API requests.
 *  '[NSURLSessionConfiguration defaultSessionConfiguration]' is used if nil is passed.
 *
 *  @param configuration Your NSURLSessionConfiguration object.
 */
+ (void)setSessionConfiguration:(QB_NULLABLE NSURLSessionConfiguration *)configuration;

/**
 *  Get custom session configuration.
 *
 *  @return Your NSURLSessionConfiguration object.
 */
+ (QB_NULLABLE NSURLSessionConfiguration *)sessionConfiguration;

/**
 *  Enable or Disable chat DNS Lookup cache for current chat endpoint
 *
 *  Caches DNS lookup for chat api endpoint.
 *
 *  @param enable YES / NO. Defaults NO
 */
+ (void)setChatDNSLookupCacheEnabled:(BOOL)enabled;

/**
 *  Get Chat DNS lookup cache enabled state
 *
 *  @return YES if cache is enabled, NO if cache is disabled.
 */
+ (BOOL)isChatDNSLookupCacheEnabled;

@end
