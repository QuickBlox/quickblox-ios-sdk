//
//  UsersDataSourceProtocol.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/15/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UsersDataSourceProtocol <NSObject>

@required
@property (strong, nonatomic, readonly) NSArray *users;
@property (strong, nonatomic) QBUUser *currentUser;
@property (strong, nonatomic, readonly) QBUUser *currentUserWithDefaultPassword;
@property (strong, nonatomic, readonly) NSString *defaultPassword;
@property (strong, nonatomic, readonly) NSArray *usersWithoutMe;

- (UIColor *)colorAtUser:(QBUUser *)user;
- (UIColor *)colorAtCurrentUser;

- (NSUInteger)indexOfUser:(QBUUser *)user;
- (NSUInteger)indexOfCurrentUser;

- (NSArray *)idsWithUsers:(NSArray *)users;
- (NSArray *)usersWithIDS:(NSArray *)ids;
- (NSArray *)usersWithIDSWithoutMe:(NSArray *)ids;
- (QBUUser *)userWithID:(NSNumber *)userID;

- (void)clear;

@optional
@property (nonatomic, strong) NSArray *tags;

- (void)addUser:(QBUUser *)user;
- (void)loadUsersWithArray:(NSArray *)users tags:(NSArray *)tags;

@end