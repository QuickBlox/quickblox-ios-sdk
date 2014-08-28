//
//  QBLLocationDataSource.h
//  LocationService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** QBLLocationDataSource class declaration  */
/** Overview:*/
/** This class provide access to current location and related things */

@interface QBLLocationDataSource : NSObject<CLLocationManagerDelegate> {
	CLLocation *currentLocation;
	CLLocationManager *locationManager;
    
    SEL action;
    id target;
}

/** Current location */
@property (nonatomic,readonly) CLLocation* currentLocation;

/** Location manager */
@property (nonatomic,readonly) CLLocationManager* locationManager;

/** Returns a Boolean value indicating whether location services are enabled on the device. */
@property (nonatomic,readonly) BOOL locationAvailable;


/** Obtain current QBLLocationDataSource instance
 @return QBLLocationDataSource initialized
 */
+ (QBLLocationDataSource *)instance;

/** 
 Set action & target for track location updates
 
 @param action A selector which will be called when location has been changed   
 @param target An object which will receive change location updates     
 */
- (void)setActionForLocationUpdate:(SEL)action target:(id)target;

/** Set minimum distance (measured in meters) a device must move laterally before an update event is generated.
 
 @param distanceFilter Minimum distance (measured in meters) a device must move laterally before an update event is generated.
 */
- (void)setDistanceFilter:(CLLocationDistance) distanceFilter;

/** Set desired accuracy of the location data.
 
 @param desiredAccuracy Desired accuracy of the location data
 */
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy;

@end