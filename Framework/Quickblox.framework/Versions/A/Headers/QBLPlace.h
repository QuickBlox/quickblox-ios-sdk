//
//  QBLPlace.h
//  LocationService
//

//  Copyright 2012 Quickblox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "QBCEntity.h"

/** QBLPlace class declaration  */
/** Overview:*/
/** This class represents place information. You can store places on server, and then retrieve them using search. See QBLocationService  */

@interface QBLPlace : QBCEntity <NSCoding, NSCopying> {
@private
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	NSString *address;
    NSString *placeDescription;
    NSString *title;
    NSUInteger geoDataID;
    NSUInteger photoID;
}

/** Latitude */
@property (nonatomic) CLLocationDegrees latitude;

/** Longitude */
@property (nonatomic) CLLocationDegrees longitude;

/** Address */
@property (nonatomic, retain) NSString *address;

/** Place description */
@property (nonatomic, retain) NSString *placeDescription;

/** Title */
@property (nonatomic, retain) NSString *title;

/** Geo data identitider */
@property (nonatomic, assign) NSUInteger geoDataID;

/** Photo identifier */
@property (nonatomic, assign) NSUInteger photoID;

/** Create new QBLPlace
 @return New instance of QBLPlace
 */
+ (QBLPlace *)place;

@end