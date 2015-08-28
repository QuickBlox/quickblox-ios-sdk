//
//  MapPin.m
//  sample-location
//
//  Created by Quickblox Team on 27.02.12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate
{
    self = [super init];
    
    if(self) {
        self.coordinate = coordinate;
    }
    
	return self;
}

@end
