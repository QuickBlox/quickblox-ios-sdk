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
 *  Default: NO
 *  Excludes QBSession.currentSession.currentUser from data source
 */
@property (nonatomic, assign) BOOL excludeCurrentUser;
- (NSUInteger)indexOfUser:(QBUUser *)user;
- (UIColor *)colorForUser:(QBUUser *)user;

@end
