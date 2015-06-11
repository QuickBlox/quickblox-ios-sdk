//
//  QBRAveragePagedResult.h
//  Quickblox
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBRAveragePagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for retrieve averages. Represent an array of average. */

@interface QBRAveragePagedResult : PagedResult {
}

/** Array of QBRAverage objects */
@property (nonatomic,readonly) NSArray *averages;

@end
