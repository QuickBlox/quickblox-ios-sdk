//
//  QBLPlaceCreateQuery.h
//  LocationService
//
//  Copyright 2012 QuickBlox  team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBLPlacesQuery.h"

@class QBLPlace;

@interface QBLPlaceCreateQuery : QBLPlacesQuery {
	QBLPlace *place;
}
@property (nonatomic, readonly) QBLPlace *place;

-(id)initWithPlace:(QBLPlace *)_place;

@end