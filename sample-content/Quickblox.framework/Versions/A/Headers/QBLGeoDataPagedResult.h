//
//  QBLGeoDataPagedResult.h
//  LocationServices
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBLGeoDataPagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for search geodata. Represent an array of geodata */

@interface QBLGeoDataPagedResult : PagedResult {
    
}
/** Array of QBLGeoData objects */
@property (nonatomic,readonly) NSArray* geodata;

@end
