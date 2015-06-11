//
//  QBLGeoDataDeleteQuery.h
//  LocationService
//
//  Created by Igor Khomenko on 2/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBLGeoDataQuery.h"

@class QBLGeoDataDeleteRequest;

@interface QBLGeoDataDeleteQuery : QBLGeoDataQuery{
	QBLGeoDataDeleteRequest *deleteRequest;
    NSUInteger geodataID;
}
@property (nonatomic, readonly) QBLGeoDataDeleteRequest *deleteRequest;
@property (nonatomic) NSUInteger geodataID;

- (id)initWithRequest:(QBLGeoDataDeleteRequest *)_deleteRequest;
- (id)initWithGeoDataID:(NSUInteger)geodataID;

@end
