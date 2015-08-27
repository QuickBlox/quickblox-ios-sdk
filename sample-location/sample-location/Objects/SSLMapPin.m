//
//  MapPin.m
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 27.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSLMapPin.h"

@implementation SSLMapPin

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate
{
    self = [super init];
    
    if(self) {
        self.coordinate = coordinate;
    }
    
	return self;
}

@end
