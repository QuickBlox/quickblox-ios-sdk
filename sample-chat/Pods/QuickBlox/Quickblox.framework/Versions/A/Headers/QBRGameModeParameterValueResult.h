//
//  QBRGameModeParameterValueResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/25/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBResult.h"

@class QBRGameModeParameterValue;

/** QBRGameModeParameterValueResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get/update game mode parameter value. Represent a single game mode parameter value. */

@interface QBRGameModeParameterValueResult : QBResult

/** An instance of QBRGameModeParameterValue.*/
@property (nonatomic, readonly) QBRGameModeParameterValue *gameModeParameterValue;

@end
