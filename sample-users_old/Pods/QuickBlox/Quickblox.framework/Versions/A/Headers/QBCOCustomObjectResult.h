//
//  QBCOCustomObjectResult.h
//  Quickblox
//
//  Created by IgorKh on 8/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

/** QBCOCustomObjectResult class declaration. */
/** Overview */
#import "Result.h"

@class QBCOCustomObject;

/** This class is an instance, which will be returned to user after he made ​​the request for create/get/update/delete custom object. Represent a single custom object. */

@interface QBCOCustomObjectResult : Result

/** An instance of QBCOCustomObject.*/
@property (nonatomic,readonly) QBCOCustomObject *object;

@end
