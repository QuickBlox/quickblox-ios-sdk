//
//  MapPin.h
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 27.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents marker on the map view
//

#import <Foundation/Foundation.h>

@interface MapPin : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
