//
//  QBRGameModePagedResult.h
//  RatingsService
//
//  Created by Igor Khomenko on 6/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBLPlacePagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get game modes. Represent an array of game modes */

@interface QBRGameModePagedResult : PagedResult{
    
}
/** Array of QBRGameMode objects */
@property (nonatomic,readonly) NSArray *gameModes;

@end
