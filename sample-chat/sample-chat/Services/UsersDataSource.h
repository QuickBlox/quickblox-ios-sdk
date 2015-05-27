//
//  UsersService.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersDataSource : NSObject

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong, readonly) NSArray *colors;

- (NSUInteger)indexOfUser:(QBUUser *)user;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (UIColor *)colorForUser:(QBUUser *)user;
- (QBUUser *)userWithID:(NSNumber *)userID;
- (NSArray *)usersWithoutMe;

@end
