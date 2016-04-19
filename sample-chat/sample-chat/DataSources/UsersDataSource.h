//
//  UsersDataSource.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Users datasource for table view.
 */
@interface UsersDataSource : NSObject<UITableViewDataSource>

- (instancetype)initWithUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

/**
 *  Adds users to datasource.
 *
 *  @param users NSArray of users to add.
 */
- (void)addUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

/**
 *  Default: empty []
 *  Excludes users with given ids from data source
 */

/**
 *  @return Array of QBUUser instances
 */
@property (nonatomic, strong, readonly) NSArray QB_GENERIC(QBUUser *) *users;
@property (nonatomic, strong) NSArray QB_GENERIC(NSNumber *) *excludeUsersIDs;
@property (nonatomic, assign) BOOL addStringLoginAsBeforeUserFullname;

- (NSUInteger)indexOfUser:(QBUUser *)user;
- (UIColor *)colorForUser:(QBUUser *)user;

@end
