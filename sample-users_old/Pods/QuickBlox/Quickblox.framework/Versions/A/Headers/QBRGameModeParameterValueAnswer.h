//
//  QBRGameModeParameterValueAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/25/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityAnswer.h"

@class QBRGameModeParameterValue;

@interface QBRGameModeParameterValueAnswer : EntityAnswer{
    
}
@property (nonatomic,readonly) QBRGameModeParameterValue *gameModeParameterValue;
@end
