//
//  QBRAverageResult.h
//  Quickblox
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"

@class QBRAverage;

/** QBRAverageResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get average. */

@interface QBRAverageResult : QBResult{
}

/** An instance of QBRAverage. */
@property (nonatomic,readonly) QBRAverage *average;

@end
