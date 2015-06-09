//
//  UsersDataSource.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersDataSource : NSObject<UITableViewDataSource>

- (instancetype)initWithUsers:(NSArray *)users;

/**
 *  Default: empty []
 *  Excludes users with given ids from data source
 */

/**
 *  @return Array of QBUUser instances
 */
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong) NSArray *excludeUsersIDs;
- (NSUInteger)indexOfUser:(QBUUser *)user;
- (UIColor *)colorForUser:(QBUUser *)user;

@end
