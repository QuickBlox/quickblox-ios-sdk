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

@interface MapPin : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate: (CLLocationCoordinate2D) _coordinate;

@end
