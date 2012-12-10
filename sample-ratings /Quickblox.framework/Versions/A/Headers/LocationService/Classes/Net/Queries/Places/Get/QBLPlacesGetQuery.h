//
//  QBLPlacesGetQuery.h
//  LocationService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLPlacesGetQuery : QBLPlacesQuery {
	PagedRequest *pagedRequest;
    NSUInteger placeID;
    
    BOOL isMultipleGet;
}
@property (nonatomic, readonly) PagedRequest *pagedRequest;
@property (nonatomic) NSUInteger placeID;

- (id)initWithPlaceID:(NSUInteger)placeID;
- (id)initWithRequest:(PagedRequest *)_pagedRequest;

@end
