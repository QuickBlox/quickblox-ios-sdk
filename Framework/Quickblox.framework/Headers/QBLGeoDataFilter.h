//
//  QBLGeoDataFilter.h
//  Quickblox
//
//  Created by Andrey Moskvin on 4/28/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "QBLocationStructs.h"

NS_ASSUME_NONNULL_BEGIN

@interface QBLGeoDataFilter : NSObject

#pragma mark -
#pragma mark Filters

/** 
 *  Time of created instance of geodata.
 *
 *  @discussion When specified, it will return only instances created at 'created_at' time. Type: Unix timestamp. 
 *  Value example: 1326471371.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/** 
 *  User id. 
 *
 *  @discussion When specified, it will return only the instances created by QBUUser with id = userID.
 */
@property (nonatomic, assign) NSUInteger userID;

/** 
 *  User ids.
 *
 *  @discussion When specified, it will return only the instances created by QBUUsers with ids = userIDs.
 */
@property (nonatomic, copy, nullable) NSArray QB_GENERIC(NSString *) *userIDs;

/** 
 *  Substring. Search for API Users full_name and login fields. 
 *
 *  @discussion When specified, it will return only the instances created by API Users who have in login
 *  or full_name passed substring.
 */
@property (nonatomic, copy, nullable) NSString *userName;

#pragma mark -
#pragma mark Diapazones

/** 
 *  Min value of created_at. 
 *
 *  @discussion If this parameter is specified, must return instances with created_at greater than or 
 *  equal to a given value. Type: Unix timestamp. Value example: 1326471371.
 */
@property (nonatomic, strong, nullable) NSDate *minCreatedAt;

/** 
 *  Max value of created_at.
 *
 *  @discussion If this parameter is specified, must return instances with created_at less than or 
 *  equal to a given value. Type: Unix timestamp. Value example: 1326471371. 
 */
@property (nonatomic, strong, nullable) NSDate *maxCreatedAt;

/** 
 *  If this parameter is correct, must return instances with coordinates that fall within the rectangle and its border. You need two points to build a rectangle (first point -- South West, second -- North East).
 */
@property (nonatomic) struct QBLGeoDataRect geoRect;

/** 
 *  With 'current_position' describes GeoCircle - "circle" on the earth's surface, given the coordinates 'current_position' and this distance in km ('radius').
 */
@property (nonatomic) CGFloat radius;

#pragma mark -
#pragma mark Sorting

/** 
 *  Indicates that the sorting should be by ascending. 
 *
 *  @discussion If this parameter is not set - the sort is by descending. 
 *  Value example: 1 (all other values ​​as well as the presence of this key parameter without 'sort_by' ​​cause an error validation). 
 */
@property (nonatomic, assign) BOOL sortAsc;

/** 
 *  Kind of sort. Posible values presented in QBGeoDataSortByKind enum. 
 */
@property (nonatomic) enum QBLGeoDataSortByKind sortBy;

#pragma mark -
#pragma mark Special

/** 
 *  The result will only include the last time data. 
 *
 *  @discussion For example, if the query is filtered by userID parameter and flag last_only is set, we get an instance - the most recent by created_at for this user, its last known position.
 *  Value example: 1 (all other values ​​cause an error validation). 
 */
@property (nonatomic, assign) BOOL lastOnly;

/** 
 *  The result will only include instances that have a non-empty 'status' field.
 *
 *  @discussion Value example: 1 (all other values ​​cause an error validation). */
@property (nonatomic, assign) BOOL status;

/** 
 *  The current position of the user. 
 *
 *  @note Used only in conjunction with the keys 'radius' and 'distance'. 
 *
 *  @discussion If this option is specified, and it does not set any of these parameters - error validation. Use '%3B' instead ';'. 
 *  Value example: 1%3B2.*/
@property (nonatomic, assign) CLLocationCoordinate2D currentPosition;

#pragma mark -
#pragma mark Parameters

/** 
 *  Converts instance to dictionary of values.
 */
- (NSDictionary *)asParameters;

@end

NS_ASSUME_NONNULL_END
