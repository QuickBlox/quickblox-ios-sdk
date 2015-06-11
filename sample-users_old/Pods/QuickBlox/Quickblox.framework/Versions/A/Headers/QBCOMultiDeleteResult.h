//
//  QBCOMultiDeleteResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

/** QBCOMultiDeleteResult class declaration. */
/** Overview */
#import "Result.h"

/** This class is an instance, which will be returned to user after he made ​​the request for delete objects by IDs */

@interface QBCOMultiDeleteResult : Result

/** An array of deleted objects IDs */
@property (nonatomic, readonly) NSArray *deletedObjectsIDs;

/** An array of objects IDs which were not found */
@property (nonatomic, readonly) NSArray *notFoundObjectsIDs;

/** An array of objects IDs which user wasn't be able to delete due to wrong permissions */
@property (nonatomic, readonly) NSArray *wrongPermissionsObjectsIDs;

@end
