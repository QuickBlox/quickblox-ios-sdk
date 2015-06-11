//
//  QBRGameModeDeleteQuery.h
//  RatingsService
//
//  Created by Andrey Kozlov on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
#import "QBRGameModeQuery.h"

@interface QBRGameModeDeleteQuery : QBRGameModeQuery {
	NSUInteger gameModeId;
}

@property (nonatomic) NSUInteger gameModeId;

- (id) initWithGameModeID:(NSUInteger)game_mode_id;

@end
