//
//  UsersDataSource.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersDataSource : NSObject<UITableViewDataSource>

/**
 *  Default: empty []
 *  Excludes users with given ids from data source
 */
@property (nonatomic, strong) NSArray *excludeUsersIDs;
- (NSUInteger)indexOfUser:(QBUUser *)user;
- (UIColor *)colorForUser:(QBUUser *)user;

@end
