//
//  UsersService.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UsersService.h"
#import "StorageManager.h"



@implementation UsersService

NSString *const kTestUsersTableKey = @"test_users";
NSString *const kUserFullNameKey = @"fullname";
NSString *const kUserLoginKey = @"login";
NSString *const kUserPasswordKey = @"password";


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

- (NSArray *)idsWithUsers:(NSArray *)users {
	
	NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
	[users enumerateObjectsUsingBlock:^(QBUUser  *obj,
										NSUInteger idx,
										BOOL *stop){
		[ids addObject:@(obj.ID)];
	}];
	
	return ids;
}

@end
