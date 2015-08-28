//
//  MapPin.h
//  sample-location
//
//  Created by Quickblox Team on 27.02.12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//
//
// This class presents marker on the map view
//

@interface MapPin : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
