//
//  QBLGeoData.h
//  LocationService
//
//  Copyright 2011 Quickblox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import <CoreLocation/CoreLocation.h>
#import "QBCEntity.h"

@class QBLGeoDataSearchRequest;
@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBLGeoData class interface.
 *  This class represents geo data - location point. You can store user locations on server, 
 *  and then retrieve them using filters and search. See QBLocationService.
 */
@interface QBLGeoData : QBCEntity <NSCoding, NSCopying>

/** 
 *  Latitude.
 */
@property (nonatomic, assign) CLLocationDegrees latitude;

/** 
 *  Longitude.
 */
@property (nonatomic, assign) CLLocationDegrees longitude;

/** 
 *  Status message.
 */
@property (nonatomic, copy, nullable) NSString *status;

/** 
 *  User ID.
 */
@property (nonatomic, assign) NSUInteger userID;

/** 
 *  User.
 */
@property (nonatomic, copy, nullable) QBUUser *user;

/** 
 *  Application identitider.
 */
@property (nonatomic, assign) NSUInteger applicationID;

/** 
 *  Timestamp of create geodata.
 */
@property (nonatomic, assign) NSUInteger createdAtTimestamp;

/** 
 *  Create new GeoData.
 *
 *  @return New instance of QBLGeoData
 */
+ (QBLGeoData *)geoData;

/** 
 *  Obtain current geo data.
 *
 *  @return QBLGeoData initialized with current location
 */
+ (QBLGeoData *)currentGeoData;

/**
 *  Obtain current geo data location.
 *
 *  @return CLLocation initialized with current geo data latitude & longitude
 */
- (CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
