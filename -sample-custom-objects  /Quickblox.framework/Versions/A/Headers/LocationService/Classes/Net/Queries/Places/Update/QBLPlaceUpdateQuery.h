//
//  QBLPlaceUpdateQuery.h
//  LocationService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLPlaceUpdateQuery : QBLPlacesQuery {
    QBLPlace *place;
}
@property (nonatomic,retain) QBLPlace *place;

- (id)initWithPlace:(QBLPlace *)place;

@end