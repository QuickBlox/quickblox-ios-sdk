//
//  QBLGeoDataAnswer.h
//  LocationService
//
//  Created by Igor Khomenko on 2/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBLGeoData;
@class QBUUserAnswer;

@interface QBLGeoDataAnswer : EntityAnswer{
@protected
	QBLGeoData *geoData;
	QBUUserAnswer *userAnswer;
}

@property (nonatomic, readonly) QBLGeoData *geoData;

@end
