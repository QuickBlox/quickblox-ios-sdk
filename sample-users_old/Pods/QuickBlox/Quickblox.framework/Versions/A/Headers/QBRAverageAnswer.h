//
//  QBRAverageAnswer.h
//  Quickblox
//
//  Created by Alexander Chaika on 05.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBRAverage;

@interface QBRAverageAnswer : EntityAnswer {
@protected
	QBRAverage *average;
}

@property (nonatomic, readonly) QBRAverage *average;

@end
