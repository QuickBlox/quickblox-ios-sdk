//
//  QBRScoreGetRequest.h
//  RatingsService
//
//  Created by Igor Khomenko on 6/22/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBRatingsEnums.h"

/** QBRScoreGetRequest class declaration. */
/** Overview */
/** This class represent an instance of request for get scores. */

@interface QBRScoreGetRequest : PagedRequest{
    // Sorting
	BOOL sortAsc;
	enum QBRScoreSortByKind sortBy;
    
    // game mode
    NSUInteger gameModeID;
    
    // filters
    NSDictionary *gameModeAdditionalParametersFilters;
}

#pragma mark -
#pragma mark Sorting

/** Indicates that the sorting should be by ascending. If this parameter is not set - the sort is by descending. Value example: 1 (all other values ​​as well as the presence of this key parameter without 'sort_by' ​​cause an error validation). */
@property (nonatomic) BOOL sortAsc;

/** Kind of sort. Posible values presented in QBRScoreSortByKind enum. */
@property (nonatomic) enum QBRScoreSortByKind sortBy;


#pragma mark -
#pragma mark Game mode

/** Game mode id. When specified, it will return only the instances with the corresponding gamemode_id. If none - in this case 404.*/
@property (nonatomic) NSUInteger gameModeID;


#pragma mark -
#pragma mark Additional parameters filters

/** One of the additional parameters of the game mode. If a parameter is specified and exists for the current game mode, it's necessary to show all instances with the parameter which is equal to the specified.*/
@property (nonatomic, retain) NSDictionary *gameModeAdditionalParametersFilters;

@end
