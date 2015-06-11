//
//  QBRScorePagedResult.h
//  RatingsService
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBRScorePagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for retrieve scores. Represent an array of scores */

@interface QBRScorePagedResult : PagedResult {
    
}

/** Array of QBRScore objects */
@property (nonatomic,readonly) NSArray *scores;

@end
