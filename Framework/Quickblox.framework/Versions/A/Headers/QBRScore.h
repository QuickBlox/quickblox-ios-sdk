//
//  QBRScore.h
//  RatingsService
//
//  Created by Igor Khomenko on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
#import "Entity.h"

/** QBRScore class declaration  */
/** Overview:*/
/** This class represents Score information. */

@interface QBRScore : Entity <NSCoding, NSCopying>{
	NSUInteger gameModeID;
	NSUInteger userID;
	NSUInteger value;
    NSArray *gameModeParameterValues;
}
/** Game mode identifier */
@property (nonatomic) NSUInteger gameModeID;

/** User identifier */
@property (nonatomic) NSUInteger userID;

/** Score value */
@property (nonatomic) NSUInteger value;

/** Array of Game mode parameter values */
@property (nonatomic, retain) NSArray *gameModeParameterValues;

/** Create new score
 @return New instance of QBRScore
 */
+ (QBRScore *)score;

@end
