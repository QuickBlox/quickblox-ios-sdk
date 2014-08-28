//
//  QBUUserPagedResult.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedResult.h"

/** QBUUserPagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request to Users module. Represent an array of users. */

@interface QBUUserPagedResult : PagedResult{
    
}

/** Array of QBUUser objects */
@property (nonatomic,readonly) NSArray *users;

@end
