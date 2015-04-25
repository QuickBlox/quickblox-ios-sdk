//
//  QBCOCustomObjectPagedResult.h
//  Quickblox
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

/** QBCOCustomObjectPagedResult class declaration. */
/** Overview */
#import "QBResult.h"

/** This class is an instance, which will be returned to user after he made ​​the request to Custom Objects module. Represent an array of custom objects. */

@interface QBCOCustomObjectPagedResult : QBResult

/** Array of QBCOCustomObject objects */
@property (nonatomic,readonly) NSArray *objects;

/** Count of objects */
@property (nonatomic, readonly) NSUInteger count;

/** Skip parameter */
@property (nonatomic, readonly) NSUInteger skip;

/** Limit parameter */
@property (nonatomic, readonly) NSUInteger limit;

/** Not found objects (!= nil in case when use multi updated objects) */
@property (nonatomic, readonly) NSArray *notFoundObjectsIDs;

@end
