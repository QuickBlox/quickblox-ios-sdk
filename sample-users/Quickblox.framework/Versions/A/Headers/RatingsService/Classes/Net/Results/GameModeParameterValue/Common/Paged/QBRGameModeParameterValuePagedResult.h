//
//  QBRGameModeParameterValuePagedResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/9/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

/** QBRGameModeParameterValuePagedResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get game mode parameter values. Represent an array of game mods parameter values */

@interface QBRGameModeParameterValuePagedResult : PagedResult{
    
}
/** Array of QBRGameModeParameterValue objects */
@property (nonatomic,readonly) NSArray *gameModeParameterValues;

@end
