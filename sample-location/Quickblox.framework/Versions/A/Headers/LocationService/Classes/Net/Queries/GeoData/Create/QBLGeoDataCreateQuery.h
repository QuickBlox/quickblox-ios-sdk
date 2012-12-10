//
//  QBLGeoDataCreateQuery.h
//  LocationService
//

//  Copyright 2011 QuickBlox  team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBLGeoData;

@interface QBLGeoDataCreateQuery : QBLGeoDataQuery {
	QBLGeoData *geodata;
}

@property (nonatomic, readonly) QBLGeoData *geodata;

-(id)initWithGeoData:(QBLGeoData *)_geodata;

@end