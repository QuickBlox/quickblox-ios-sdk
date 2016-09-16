//
//  QBLPlace.h
//  LocationService
//

//  Copyright 2012 Quickblox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import <CoreLocation/CoreLocation.h>
#import "QBCEntity.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBLPlace class interface.
 *  This class represents place information. 
 *  You can store places on server, and then retrieve them using search.
 */
@interface QBLPlace : QBCEntity <NSCoding, NSCopying>

/** 
 *  Latitude.
 */
@property (nonatomic, assign) CLLocationDegrees latitude;

/** 
 *  Longitude.
 */
@property (nonatomic, assign) CLLocationDegrees longitude;

/**
 *  Address.
 */
@property (nonatomic, copy, nullable) NSString *address;

/** 
 *  Place description.
 */
@property (nonatomic, copy, nullable) NSString *placeDescription;

/** 
 *  Title.
 */
@property (nonatomic, copy, nullable) NSString *title;

/** 
 *  Geo data identitider.
 */
@property (nonatomic, assign) NSUInteger geoDataID;

/** 
 *  Photo identifier.
 */
@property (nonatomic, assign) NSUInteger photoID;

/** 
 *  Create new QBLPlace.
 *
 *  @return New instance of QBLPlace
 */
+ (QBLPlace *)place;

@end

NS_ASSUME_NONNULL_END
