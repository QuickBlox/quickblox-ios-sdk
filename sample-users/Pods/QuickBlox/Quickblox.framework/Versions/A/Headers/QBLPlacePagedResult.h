//
//  QBLPlacePagedResult.h
//  LocationServices
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBLPlacePagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for search places. Represent an array of places */

@interface QBLPlacePagedResult : PagedResult {
    
}
/** Array of QBLPlace objects */
@property (nonatomic,readonly) NSArray *places;

@end
