//
//  Consts.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

#define dataElement @"data"
#define permissionsElement @"permissions"

// Permissions access types
extern NSString *const QB_NONNULL_S kQBCOPermissionsAccessOpen;
extern NSString *const QB_NONNULL_S kQBCOPermissionsAccessOwner;
extern NSString *const QB_NONNULL_S kQBCOPermissionsAccessOpenForUsersIDs;
extern NSString *const QB_NONNULL_S kQBCOPermissionsAccessOpenForGroups;

typedef NS_ENUM(NSUInteger, QBCOAggregationOperator) {
    QBCOAggregationOperatorNone,
    QBCOAggregationOperatorAverage,
    QBCOAggregationOperatorMinimum,
    QBCOAggregationOperatorMaximum,
    QBCOAggregationOperatorSummary
};