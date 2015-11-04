//
//  UsersDataSource.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "QBUUser+IndexAndColor.h"

@interface UsersDataSource : NSObject

@property (assign, nonatomic) ListOfUsers list;
@property (strong, nonatomic, readonly) NSArray *users;
@property (strong, nonatomic, readonly) QBUUser *currentUser;
@property (strong, nonatomic, readonly) NSArray *usersWithoutMe;

+ (instancetype)instance;

- (void)loadUsersWithList:(ListOfUsers)list;
- (UIColor *)colorAtUser:(QBUUser *)user;
- (NSString *)strWithList:(ListOfUsers)list;

- (NSUInteger)indexOfUser:(QBUUser *)user;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (NSArray *)usersWithIDS:(NSArray *)ids;
- (NSArray *)usersWithIDSWithoutMe:(NSArray *)ids;
- (QBUUser *)userWithID:(NSNumber *)userID;

@end
