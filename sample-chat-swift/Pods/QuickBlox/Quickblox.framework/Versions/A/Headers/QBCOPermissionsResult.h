//
//  QBCOPermissionsResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

/** QBCOPermissionsResult class declaration. */
/** Overview */
#import "QBResult.h"

@class QBCOPermissions;

/** This class is an instance, which will be returned to user after he made ​​the request for get permissions for custom object. */

@interface QBCOPermissionsResult : QBResult

/** An instance of QBCOPermissions.*/
@property (nonatomic,readonly) QBCOPermissions *permissions;

@end
