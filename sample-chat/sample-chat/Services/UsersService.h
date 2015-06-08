//
//  UsersService.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersService : NSObject

- (instancetype)init __attribute__((unavailable("unavailable, use -initWithContactListService: instead")));
- (instancetype)initWithContactListService:(QMContactListService *)contactListService;

/**
 *  Download users from 'test_users' CO table
 */
- (void)usersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 *  Get cached users with given IDs
 *
 *  @param usersIDs   array of NSString
 *  @param completion completion block
 */
- (void)retrieveUsersWithIDs:(NSArray *)usersIDs completion:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))completion;

- (QBUUser *)userWithID:(NSNumber *)userID;
- (NSArray *)usersWithoutCurrentUser;
- (NSArray *)idsWithUsers:(NSArray *)users;

@end
