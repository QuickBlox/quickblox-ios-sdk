//
//  QBRGameModeParameterValue.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/25/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

/** QBRGameModeParameterValue class declaration  */
/** Overview:*/
/** This class represents value of game mode parameter. */

@interface QBRGameModeParameterValue : Entity <NSCoding, NSCopying>{
    NSUInteger gameModeParameterID; 
    NSUInteger scoreID;
    NSString *value;
}

/** Game mode parameter identifier */
@property (nonatomic) NSUInteger gameModeParameterID; 

/** Score identifier */
@property (nonatomic) NSUInteger scoreID;

/** Value */
@property (nonatomic, copy) NSString *value;

/** Create new game mode parameter value
 @return New instance of QBRGameModeParameterValue
 */
+ (QBRGameModeParameterValue *)gameModeParameterValue;

@end

