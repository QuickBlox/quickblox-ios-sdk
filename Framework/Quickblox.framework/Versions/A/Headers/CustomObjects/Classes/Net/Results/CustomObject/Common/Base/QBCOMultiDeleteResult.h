//
//  QBCOMultiDeleteResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

/** QBCOMultiDeleteResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for delete objects by IDs */

@interface QBCOMultiDeleteResult : Result

@property (nonatomic, readonly) NSArray *deletedObjectsIDs;
@property (nonatomic, readonly) NSArray *notFoundObjectsIDs;
@property (nonatomic, readonly) NSArray *wrongPermissionsObjectsIDs;

@end
