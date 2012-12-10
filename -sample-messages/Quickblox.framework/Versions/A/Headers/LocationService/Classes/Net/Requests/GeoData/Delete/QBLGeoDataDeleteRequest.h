//
//  QBLGeoDataDeleteRequest.h
//  LocationServices
//
//  Created by Igor Khomenko on 2/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBLGeoDataDeleteRequest class declaration. */
/** Overview */
/** This class represent an instance of request for delete geodata. */

@interface QBLGeoDataDeleteRequest : Request{
    NSUInteger days;
}

/** Maximum age of data that must remain in the database after a query. */
@property (nonatomic) NSUInteger days;

@end
