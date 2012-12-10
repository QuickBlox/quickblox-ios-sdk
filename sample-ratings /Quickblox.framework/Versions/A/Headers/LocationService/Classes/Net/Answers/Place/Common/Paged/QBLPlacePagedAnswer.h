//
//  QBLPlacePagedAnswer.h
//  LocationService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLPlacePagedAnswer : PagedAnswer{
	QBLPlaceAnswer *placeAnswer;
	NSMutableArray *places;
}

@property (nonatomic, retain) NSMutableArray *places;

@end
