//
//  UsersDataSource.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/12/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//
#import "UsersDataSourceProtocol.h"

@interface UsersDataSource : NSObject <UsersDataSourceProtocol>

@property (strong, nonatomic, readonly) NSArray *users;
@property (strong, nonatomic) QBUUser *currentUser;
@property (strong, nonatomic, readonly) QBUUser *currentUserWithDefaultPassword;
@property (strong, nonatomic, readonly) NSString *defaultPassword;
@property (strong, nonatomic, readonly) NSArray *usersWithoutMe;
@property (nonatomic, strong) NSArray *tags;
/**
 *  Loading users
 *
 *  @param users array of QBUUser instance
 */
- (void)loadUsersWithArray:(NSArray *)users tags:(NSArray *)tags;

/// @return random color
- (UIColor *)colorAtUser:(QBUUser *)user;

@end
