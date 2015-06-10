//
//  Consts.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#define dataElement @"data"
#define permissionsElement @"permissions"

// Permissions access types
extern NSString *const kQBCOPermissionsAccessOpen;
extern NSString *const kQBCOPermissionsAccessOwner;
extern NSString *const kQBCOPermissionsAccessOpenForUsersIDs;
extern NSString *const kQBCOPermissionsAccessOpenForGroups;

typedef NS_ENUM(NSUInteger, QBCOAggregationOperator) {
    QBCOAggregationOperatorNone,
    QBCOAggregationOperatorAverage,
    QBCOAggregationOperatorMinimum,
    QBCOAggregationOperatorMaximum,
    QBCOAggregationOperatorSummary
};