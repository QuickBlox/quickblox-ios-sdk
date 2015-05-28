//
//  UsersService.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersService : NSObject

- (void)usersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

- (NSUInteger)indexOfUser:(QBUUser *)user;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (UIColor *)colorForUser:(QBUUser *)user;
- (QBUUser *)userWithID:(NSNumber *)userID;
- (NSArray *)usersWithoutCurrentUser;

@end
