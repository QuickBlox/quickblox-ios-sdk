//
//  QBLPlaceAnswer.h
//  LocationService
//
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBLPlace;

@interface QBLPlaceAnswer : EntityAnswer{
@protected
	QBLPlace *place;
}

@property (nonatomic, readonly) QBLPlace *place;

@end
