//
//  Consts.h
//  Quickblox
//
//  Created by QuickBlox team on 7/5/13.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#define dataElement @"data"
#define permissionsElement @"permissions"

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
