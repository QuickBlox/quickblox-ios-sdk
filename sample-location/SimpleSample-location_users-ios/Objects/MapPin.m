//
//  MapPin.m
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 27.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin
@synthesize  coordinate;
@synthesize title, subtitle;

- (id)initWithCoordinate: (CLLocationCoordinate2D) _coordinate{
    self = [super init];
    if(self){
        self.coordinate = _coordinate;
    }
    
	return self;
}

- (void)dealloc{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
