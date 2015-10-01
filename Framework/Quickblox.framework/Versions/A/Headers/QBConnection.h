//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>


typedef enum QBConnectionZoneType{
    QBConnectionZoneTypeAutomatic = 1, //Default. Endpoints are loaded from QuickBlox
    QBConnectionZoneTypeProduction      = 2,
    QBConnectionZoneTypeDevelopment     = 3,
    QBConnectionZoneTypeStage           = 4
} QBConnectionZoneType;

@class QBRequest;
@class QBResponse;
@class QBSessionParameters;

@interface QBConnection : NSObject

#pragma mark - Settings methods
/**
* Setting API Key for Quickblox API
*
* @param serviceKey - NSString value of API Key.
*/
+ (void)registerServiceKey:(QB_NONNULL NSString *)serviceKey;

/**
* Setting API Secret for Quickblox API
*
* @param serviceSecret - NSString value of API Secret.
*/
+ (void)registerServiceSecret:(QB_NONNULL NSString *)serviceSecret;

/**
* Allow to change Services Zone to work with Development and Staging environments
*
* @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
*/
+ (void)setServiceZone:(QBConnectionZoneType)serviceZone;

/**
 *  Return current Service Zone
 *
 *  @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeAutomatic
 */
+ (QBConnectionZoneType)currentServiceZone;

/**
* A Boolean value indicating whether the manager is enabled.

* If YES, the manager will change status bar network activity indicator according to network operation notifications it receives. The default value is NO.
*/
+ (void)setNetworkIndicatorManagerEnabled:(BOOL)enabled;

/**
 A Boolean value indicating whether the network activity indicator is currently displayed in the status bar.
*/
+ (BOOL)isNetworkIndicatorVisible;

/**
* Allow to set custom domain for specific zone.
*
* @param apiDomain - Domain for service i.e. http://my_custom_domain.com. Possible to pass nil to return to default settings
* @param zone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
*/
+ (void)setApiDomain:(QB_NULLABLE NSString *)apiDomain forServiceZone:(enum QBConnectionZoneType)zone;

/**
 *  Returns Api Domain for current zone
 *
 *  @return NSString value of Api Domain
 */
+ (QB_NULLABLE NSString *)currentApiDomain;

@end
