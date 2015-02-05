//
//  QBRScoreResult.h
//  RatingsService
//
//  Created by Alexander Chaika on 02.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"

@class QBRScore;

/** QBRScoreResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get/edit score. Represent a single score. */

@interface QBRScoreResult : QBResult{
}

/** An instance of QBRScore. */
@property (nonatomic,readonly) QBRScore *score;

@end
