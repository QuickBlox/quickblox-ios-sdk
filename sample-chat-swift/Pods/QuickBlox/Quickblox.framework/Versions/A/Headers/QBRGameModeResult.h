//
//  QBRAddGameModeResult.h
//  RatingsService
//
//  Created by Andrey Kozlov on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
#import "QBResult.h"

@class QBRGameMode;

/** QBRGameModeResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get/update game mode. Represent a single game mode. */

@interface QBRGameModeResult : QBResult{
}

/** An instance of QBRGameMode.*/
@property (nonatomic, readonly) QBRGameMode *gameMode;

@end
