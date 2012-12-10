//
//  QBLGeoDataGetQuery.h
//  LocationService
//
//  Created by Igor Khomenko on 6/12/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBLGeoDataGetRequest;

@interface QBLGeoDataGetQuery : QBLGeoDataQuery{
    QBLGeoDataGetRequest *searchRequest;
    NSUInteger geodataID;
    
    BOOL isMultipleGet;
}
@property (nonatomic) NSUInteger geodataID;
@property (nonatomic,readonly) QBLGeoDataGetRequest *searchRequest;

- (id)initWithRequest:(QBLGeoDataGetRequest *)_searchrequest;
- (id)initWithGeoDataID:(NSUInteger)geodataID;

@end
