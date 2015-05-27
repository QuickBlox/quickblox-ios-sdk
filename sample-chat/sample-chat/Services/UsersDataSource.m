//
//  UsersService.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersDataSource.h"

@interface UsersDataSource()
@property (nonatomic, strong) NSArray *colors;
@end

@implementation UsersDataSource

NSString *const kTestUsersTableKey = @"test_users";
NSString *const kUserFullNameKey = @"fullname";
NSString *const kUserLoginKey = @"login";
NSString *const kUserPasswordKey = @"password";

- (instancetype)init {
	self = [super init];
	if( self) {
		_colors =
		@[[UIColor colorWithRed:0.992 green:0.510 blue:0.035 alpha:1.000],
		  [UIColor colorWithRed:0.039 green:0.376 blue:1.000 alpha:1.000],
		  [UIColor colorWithRed:0.984 green:0.000 blue:0.498 alpha:1.000],
		  [UIColor colorWithRed:0.204 green:0.644 blue:0.251 alpha:1.000],
		  [UIColor colorWithRed:0.580 green:0.012 blue:0.580 alpha:1.000],
		  [UIColor colorWithRed:0.396 green:0.580 blue:0.773 alpha:1.000],
		  [UIColor colorWithRed:0.765 green:0.000 blue:0.086 alpha:1.000],
		  [UIColor colorWithWhite:0.537 alpha:1.000],
		  [UIColor colorWithRed:0.786 green:0.706 blue:0.000 alpha:1.000],
		  [UIColor colorWithRed:0.740 green:0.624 blue:0.797 alpha:1.000]];
	}
	return self;
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
	
	return [self.users indexOfObject:user];
}

- (NSArray *)idsWithUsers:(NSArray *)users {
	
	NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
	[users enumerateObjectsUsingBlock:^(QBUUser  *obj,
										NSUInteger idx,
										BOOL *stop){
		[ids addObject:@(obj.ID)];
	}];
	
	return ids;
}

- (UIColor *)colorForUser:(QBUUser *)user {
	NSUInteger idx = [self.users indexOfObject:user];
	return self.colors[idx];
}

- (QBUUser *)userWithID:(NSNumber *)userID {
	
	__block QBUUser *resultUser = nil;
	[self.users enumerateObjectsUsingBlock:^(QBUUser *user,
											 NSUInteger idx,
											 BOOL *stop) {
		
		if (user.ID == userID.integerValue) {
			resultUser =  user;
			*stop = YES;
		}
	}];
	
	return resultUser;
}

- (NSArray *)usersWithoutMe {
	NSMutableArray *usersWithoutMe = [self.users mutableCopy];
	if( [QBSession currentSession].currentUser ) {
		[usersWithoutMe removeObject:[QBSession currentSession].currentUser];
	}
	
	return usersWithoutMe;
}
@end
