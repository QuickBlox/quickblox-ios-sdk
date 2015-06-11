//
//  QBRAverageGetQuery.h
//  Quickblox
//
//  Created by Alexander Chaika on 06.04.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRAverageQuery.h"

@interface QBRAverageGetQuery : QBRAverageQuery {
    NSUInteger gameModeId;
}

@property (nonatomic, readonly) NSUInteger gameModeId;

-(id)initWithGameModeId:(NSUInteger)_gameModeId;

@end
