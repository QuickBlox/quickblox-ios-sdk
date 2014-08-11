//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBConnectionZoneType) {
    QBConnectionZoneTypeProduction      = 1,
    QBConnectionZoneTypeDevelopment     = 2,
    QBConnectionZoneTypeStage           = 3
};

@class QBRequest;

@interface QBConnection : NSObject

#pragma mark - Settings methods
/**
* Setting API Key for Quickblox API
*
* @param serviceKey - NSString value of API Key.
*/
+ (void)registerServiceKey:(NSString *)serviceKey;

/**
* Setting API Secret for Quickblox API
*
* @param serviceSecret - NSString value of API Secret.
*/
+ (void)registerServiceSecret:(NSString *)serviceSecret;

/**
* Allow to change Services Zone to work with Development and Staging environments
*
* @param serviceZone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
*/
+ (void)setServiceZone:(QBConnectionZoneType)serviceZone;

/**
* Allow to set custom domain for specific zone.
*
* @param apiDomain - Domain for service i.e. http://my_custom_domain.com. Possible to pass nil to return to default settings
* @param zone - Service Zone. One from QBConnectionZoneType. Default - QBConnectionZoneTypeProduction
*/
+ (void)setApiDomain:(NSString *)apiDomain forServiceZone:(enum QBConnectionZoneType)zone;

@end