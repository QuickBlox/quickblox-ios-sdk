//
//  QBRGameModeParameterValueCreateQuery.h
//  RatingsService
//
//  Created by Igor Khomenko on 6/25/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBRGameModeParameterValueCreateQuery : QBRGameModeParameterValueQuery{
    QBRGameModeParameterValue *gameModeParameterValue;
}

@property (nonatomic, readonly) QBRGameModeParameterValue *gameModeParameterValue;

-(id)initWithGameModeParameterValue:(QBRGameModeParameterValue *)gameModeParameterValue;

@end