//
//  UsersService.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersService.h"
#import "StorageManager.h"

@interface UsersService()
@property (nonatomic, strong) NSArray *colors;
@end

@implementation UsersService

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

- (void)usersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	
	NSString *const kTestUsersTableKey = @"test_users";
	NSString *const kUserFullNameKey = @"fullname";
	NSString *const kUserLoginKey = @"login";
	NSString *const kUserPasswordKey = @"password";
	
	if( StorageManager.instance.users.count != 0 ){
		if( successBlock != nil ) {
			successBlock(StorageManager.instance.users);
		}
		return; // do not download again
	}
	
	[QBRequest objectsWithClassName:kTestUsersTableKey successBlock:^(QBResponse *response, NSArray *objects) {
		
		NSMutableArray *users = [NSMutableArray arrayWithCapacity:objects.count];
		
		for( QBCOCustomObject *cObject in objects ){
			QBUUser *user = [[QBUUser alloc] init];
			user.fullName = cObject.fields[kUserFullNameKey];
			user.ID = cObject.userID;
			user.login = cObject.fields[kUserLoginKey];
			user.password = cObject.fields[kUserPasswordKey];
			
			[users addObject:user];
		}
		
		StorageManager.instance.users = [users copy];
		
		if( successBlock != nil ) {
			successBlock(users);
		}
		
	} errorBlock:^(QBResponse *response) {
		if( errorBlock != nil ) {
			errorBlock(response);
		}
		NSLog(@"error: %@", response.error.error);
	}];
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
	
	return [StorageManager.instance.users indexOfObject:user];
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
	NSUInteger idx = [StorageManager.instance.users indexOfObject:user];
	return self.colors[idx];
}

- (QBUUser *)userWithID:(NSNumber *)userID {
	
	__block QBUUser *resultUser = nil;
	[StorageManager.instance.users enumerateObjectsUsingBlock:^(QBUUser *user,
											 NSUInteger idx,
											 BOOL *stop) {
		
		if (user.ID == userID.integerValue) {
			resultUser =  user;
			*stop = YES;
		}
	}];
	
	return resultUser;
}

- (NSArray *)usersWithoutCurrentUser {
	NSMutableArray *usersWithoutCurrentUser = [StorageManager.instance.users mutableCopy];
	if( [QBSession currentSession].currentUser ) {
		[usersWithoutCurrentUser removeObject:[QBSession currentSession].currentUser];
	}
	
	return usersWithoutCurrentUser;
}
@end
