//
//  QBRGameModeAnswer.h
//  RatingsService
//
//  Created by Andrey Kozlov on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "EntityAnswer.h"

@class QBRGameMode;

@interface QBRGameModeAnswer : EntityAnswer {
}

@property (nonatomic,readonly) QBRGameMode *gamemode;

@end
