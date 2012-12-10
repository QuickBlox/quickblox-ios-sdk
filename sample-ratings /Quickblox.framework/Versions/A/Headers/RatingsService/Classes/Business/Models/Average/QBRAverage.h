//
//  QBRAverage.h
//  RatingsService
//
//  Created by Igor Khomenko on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

/** QBRAverage class declaration  */
/** Overview:*/
/** This class represents avarage information. */

@interface QBRAverage : Entity <NSCoding, NSCopying>{
	NSUInteger gameModeID;
	CGFloat value;
}
/** Game mode identifier */
@property (nonatomic) NSUInteger gameModeID;

/** Avarage value */
@property (nonatomic) CGFloat value;

@end
