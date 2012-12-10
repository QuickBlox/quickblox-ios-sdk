/*
 *  Consts.h
 *  LocationService
 *
 
 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

#define kLocationServiceErrorDomain @"LocationServiceErrorDomain"
#define kLocationServiceException @"LocationServiceException"


#define kLocationServiceDefaultSort GeoDataSortByKindNone
#define kLocationServiceDefaultSortIsAsc NO
#define kLocationServiceDefaultLastOnly NO
#define kLocationServiceDefaultStatus NO
#define kLocationServiceCoordinateNotSet 200
#define kLocationServiceRadiusNotSet 0
#define kLocationServiceDaysNotSet 0
#define kLocationServiceGeoPointNotSet [QBLGPConst coordinateWithLatitude:kLocationServiceCoordinateNotSet longitude:kLocationServiceCoordinateNotSet]
#define kLocationServiceGeoRectNotSet  [QBLGPConst geodataRectWithNW:kLocationServiceGeoPointNotSet SE:kLocationServiceGeoPointNotSet]
#define kLocationServiceLocationNotSet [[[CLLocation alloc] initWithLatitude:kLocationServiceCoordinateNotSet longitude:kLocationServiceCoordinateNotSet] autorelease]


#define geoDatumElement @"geo-datum"
#define geoDataElement @"geo-data"
#define locationElement @"location"
#define locationsElement @"locations"

#define placesElement @"places"
#define placeElement @"place"
