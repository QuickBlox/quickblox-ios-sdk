//
//  QBLGPConst.h
//  LocationService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBLGPConst : NSObject {

}
+ (CLLocationCoordinate2D) coordinateWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (struct QBLGeoDataRect) geodataRectWithNW:(CLLocationCoordinate2D)NWpoint SE:(CLLocationCoordinate2D)SEpoint;
+ (BOOL) coordinate:(CLLocationCoordinate2D)coordinate1 isEqualTo:(CLLocationCoordinate2D)coordinate2;
+ (BOOL) geodataRect:(struct QBLGeoDataRect)rect1 isEqualTo:(struct QBLGeoDataRect)rect2;

@end
