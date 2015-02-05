//
//  QBMEventPagedResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBResult.h"

/** QBMEventPagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get events. */

@interface QBMEventPagedResult : QBResult

/** Array of QBMEvent objects */
@property (nonatomic,readonly) NSArray *events;

@end
