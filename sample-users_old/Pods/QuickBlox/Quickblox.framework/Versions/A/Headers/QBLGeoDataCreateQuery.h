//
//  QBLGeoDataCreateQuery.h
//  LocationService
//

//  Copyright 2011 QuickBlox  team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBLGeoDataQuery.h"

@class QBLGeoData;

@interface QBLGeoDataCreateQuery : QBLGeoDataQuery {
	QBLGeoData *geodata;
    NSString *pushText;
    CGFloat radius;
}

@property (nonatomic, readonly) QBLGeoData *geodata;
@property (nonatomic, retain) NSString *pushText;
@property (nonatomic, assign) CGFloat radius;

-(id)initWithGeoData:(QBLGeoData *)_geodata;

@end