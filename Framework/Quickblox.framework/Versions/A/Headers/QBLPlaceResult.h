//
//  QBLPlaceResult.h
//  LocationServices
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"

@class QBLPlace;

/** QBLPlaceResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/search place. Represent a single place. */

@interface QBLPlaceResult : QBResult{
}

/** An instance of QBLPlace.*/
@property (nonatomic,readonly) QBLPlace *place;

@end
