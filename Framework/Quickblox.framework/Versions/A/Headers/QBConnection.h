//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBSettings.h"

@class QBRequest;
@class QBResponse;
@class QBSessionParameters;

@interface QBConnection : NSObject

#pragma mark - Settings methods
/**
 *  Setting API Key for Quickblox API
 *
 *  @param serviceKey - NSString value of API Key.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setAuthKey:] instead.
 */
+ (void)registerServiceKey:(QB_NONNULL NSString *)serviceKey DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setAuthKey:] instead");

/**
 *  Setting API Secret for Quickblox API
 *
 *  @param serviceSecret - NSString value of API Secret.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setAuthSecret:] instead.
 */
+ (void)registerServiceSecret:(QB_NONNULL NSString *)serviceSecret DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setAuthSecret:] instead");

/**
 *  Allow to change Services Zone to work with Development and Staging environments
 *
 *  @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setServiceZone:] instead.
 */
+ (void)setServiceZone:(QBConnectionZoneType)serviceZone DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setServiceZone:] instead");

/**
 *  Return current Service Zone
 *
 *  @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeAutomatic
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings currentServiceZone] instead.
 */
+ (QBConnectionZoneType)currentServiceZone DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings currentServiceZone] instead");

/**
 *  A Boolean value indicating whether the manager is enabled.
 *  If YES, the manager will change status bar network activity indicator according to network operation notifications it receives. The default value is NO.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setNetworkIndicatorManagerEnabled:] instead.
 */
+ (void)setNetworkIndicatorManagerEnabled:(BOOL)enabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setNetworkIndicatorManagerEnabled:] instead");

/**
 *  A Boolean value indicating whether the network activity indicator is currently displayed in the status bar.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings isNetworkIndicatorVisible] instead.
 */
+ (BOOL)isNetworkIndicatorVisible DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings isNetworkIndicatorVisible] instead");

/**
 *  Allow to set custom domain for specific zone.
 *
 *  @param apiDomain - Domain for service i.e. http://my_custom_domain.com. Possible to pass nil to return to default settings
 *  @param zone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setApiEndpoint:chatEndpoint:forServiceZone:] instead.
 */
+ (void)setApiDomain:(QB_NULLABLE NSString *)apiDomain forServiceZone:(enum QBConnectionZoneType)zone DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setApiEndpoint:chatEndpoint:forServiceZone:] instead");

/**
 *  Returns Api Domain for current zone
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings apiEndpoint] instead.
 *
 *  @return NSString value of Api Domain
 */
+ (QB_NULLABLE NSString *)currentApiDomain DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings apiEndpoint] instead");

@end
