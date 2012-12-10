//
//  DataManager.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/19/12.
//
//

#import "DataManager.h"

static DataManager *instance = nil;

@implementation DataManager

@synthesize checkinArray;
@synthesize currentUser = _currentUser;

+ (DataManager *)shared {
	@synchronized (self) {
		if (instance == nil){
            instance = [[self alloc] init];
        }
	}
	
	return instance;
}

-(void) dealloc{
    [checkinArray release];
    [_currentUser release];
	[super dealloc];
}

@end