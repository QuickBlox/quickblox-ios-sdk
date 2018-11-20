//
//  QBCustomObjectsConsts.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

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
