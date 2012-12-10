//
//  QBLGeoDataUpdateQuery.h
//  LocationService
//
//  Created by Igor Khomenko on 5/12/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBLGeoData;

@interface QBLGeoDataUpdateQuery : QBLGeoDataQuery{
    QBLGeoData *geodata;
}

@property (nonatomic, readonly) QBLGeoData *geodata;

-(id)initWithGeoData:(QBLGeoData *)_geodata;

@end
