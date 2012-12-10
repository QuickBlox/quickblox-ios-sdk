//
//  QBRGameMode.h
//  RatingsService
//
//  Created by Igor Khomenko on 6/7/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBRGameMode class declaration  */
/** Overview:*/
/** This class represents GameMode information. */

@interface QBRGameMode : Entity <NSCoding, NSCopying>{
    NSString *title;
    NSUInteger applicationID;
    NSUInteger userID;
}

/** Game mode title */
@property (nonatomic, retain) NSString *title;

/** Application identifier */
@property (nonatomic, assign) NSUInteger applicationID;

/** User identifier */
@property (nonatomic, assign) NSUInteger userID;

/** Create new game mode
 @return New instance of QBRGameMode
 */
+ (QBRGameMode *)gameMode;

@end
