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

@property (strong, nonatomic) QMContactListService *contactListService;

/// @return array of cached QBUUser instances
- (void)cachedUsersWithCompletion:(void(^)(NSArray *users))completion;

/**
 *  Download latest users from 'test_users' CO table
 *  or return users if they were downloaded before
 */
- (void)downloadLatestUsersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 *  Get cached users with given IDs
 *
 *  @param usersIDs   array of NSString
 *  @param completion completion block
 */
- (void)retrieveUsersWithIDs:(NSArray *)usersIDs completion:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users))completion;

/**
 *  Returns array of users without current user.
 *
 *  @return NSArray of users.
 */
- (NSArray *)usersWithoutCurrentUser;

/**
 *  Extracts IDs from array of users.
 *
 *  @param users NSArray of users.
 *
 *  @return NSArray of NSNumber IDs.
 */
- (NSArray *)idsWithUsers:(NSArray *)users;

@end
