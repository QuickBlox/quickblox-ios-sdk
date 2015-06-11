//
//  QBRGameModeParameterValueGetQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/25/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBRGameModeParameterValueQuery.h"

@interface QBRGameModeParameterValueGetQuery : QBRGameModeParameterValueQuery{
    NSUInteger gameModeParameterValueID;
}

@property (nonatomic, readonly) NSUInteger gameModeParameterValueID;

-(id)initWithGameModeParameterValueID:(NSUInteger)gameModeParameterValueID;

@end
