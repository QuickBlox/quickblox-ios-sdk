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

/** QBLGeoData class declaration  */
/** Overview:*/
/** This class represents geo data - location point. You can store user locations on server, and then retrieve them using filters and search. See QBLocationService  */

@interface QBLGeoData : QBCEntity <NSCoding, NSCopying> {
@private
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
    NSString *status;
    
    NSUInteger userID;
	QBUUser *user;
    NSUInteger applicationID;
    
    NSUInteger createdAtTimestamp;
}
/** Latitude */
@property (nonatomic) CLLocationDegrees latitude;

/** Longitude */
@property (nonatomic) CLLocationDegrees longitude;

/** Status message */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *status;

/** User ID */
@property (nonatomic, assign) NSUInteger userID;

/** User */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) QBUUser *user;

/** Application identitider */
@property (nonatomic, assign) NSUInteger applicationID;

/** Timestamp of create geodata */
@property (nonatomic) NSUInteger createdAtTimestamp;

/** Create new GeoData
 @return New instance of QBLGeoData
 */
+ (QB_NONNULL QBLGeoData *)geoData;

/** Obtain current geo data
 @return QBLGeoData initialized with current location
 */
+ (QB_NONNULL QBLGeoData *)currentGeoData;

/** Obtain current geo data location
 @return CLLocation initialized with current geo data latitude & longitude
 */
- (QB_NONNULL CLLocation *) location;

@end