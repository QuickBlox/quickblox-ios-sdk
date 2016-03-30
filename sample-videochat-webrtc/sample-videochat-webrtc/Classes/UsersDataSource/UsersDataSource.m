//
//  UsersDataSource.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/12/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "UsersDataSource.h"

@interface UsersDataSource()
@property (strong, nonatomic) NSMutableDictionary *innerUsers;
@end

@implementation UsersDataSource

NSString *const kDefaultPassword = @"x6Bt0VDy5";

- (instancetype)init {
	self = [super init];
	if (self) {
		_innerUsers = [NSMutableDictionary dictionary];
	}
	return self;
}

- (QBUUser *)currentUser {

	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	// try to retrieve cached user if exists
	if([userDef objectForKey:@"user"]){
		id object = [NSKeyedUnarchiver unarchiveObjectWithData:[userDef objectForKey:@"user"]];
		
		if ([object isKindOfClass:[QBUUser class]]) {
			return object;
		}
	}

	return nil;
}

- (void)setCurrentUser:(QBUUser *)currentUser {
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	
	if (!currentUser) {
		
		[userDef removeObjectForKey:@"user"];
		[self.innerUsers removeObjectForKey:@(currentUser.ID)];
	}
	else {
		
		[userDef setObject:[NSKeyedArchiver archivedDataWithRootObject:currentUser] forKey:@"user"];
		self.innerUsers[@(currentUser.ID)] = currentUser;
	}
	
	[userDef synchronize];
}

- (QBUUser *)currentUserWithDefaultPassword {

	QBUUser *user = [self currentUser];
	user.password = kDefaultPassword;
	return user;
}

- (NSString *)defaultPassword {
	return kDefaultPassword;
}

- (UIColor *)colorAtCurrentUser {
	return [self colorAtUser:self.currentUser];
}

- (NSArray *)users {
	return [self.innerUsers allValues];
}

- (NSArray *)usersWithoutMe {
	NSMutableDictionary *users = [self.innerUsers mutableCopy];
	[users removeObjectForKey:@(self.currentUser.ID)];
	
	return [users allValues];
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
	NSUInteger indexOfUser = [self.users indexOfObject:user];
	NSAssert(indexOfUser != NSNotFound, @"User not found in array");
	return indexOfUser;
}

- (NSUInteger)indexOfCurrentUser {
	return [self indexOfUser:self.currentUser];
}

- (NSArray *)idsWithUsers:(NSArray *)users {

	NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];

	[users enumerateObjectsUsingBlock:^(QBUUser  *obj, NSUInteger idx, BOOL *stop) {

		[ids addObject:@(obj.ID)];
	}];

	return ids.copy;
}

- (NSArray *)usersWithIDS:(NSArray *)ids {

	NSMutableArray *users = [NSMutableArray arrayWithCapacity:ids.count];

	for(NSNumber *userID in ids) {

		QBUUser *user = [self userWithID:userID];
		[users addObject:user];
	}

	return [users copy];
}

- (NSArray *)usersWithIDSWithoutMe:(NSArray *)ids {

	NSMutableArray *users = [self usersWithIDS:ids].mutableCopy;
	[users removeObject:self.currentUser];

	return users.copy;
}

- (QBUUser *)userWithID:(NSNumber *)userID {
	return self.innerUsers[userID];
}

- (void)addUser:(QBUUser *)user {
	self.innerUsers[@(user.ID)] = user;
}

- (void)loadUsersWithArray:(NSArray *)users tags:(NSArray *)tags {
	[self.innerUsers removeAllObjects];
	for (QBUUser *user in [users copy]) {
		self.innerUsers[@(user.ID)] = user;
	}
	self.tags = [tags copy];
}

- (void)clear {
	[self.innerUsers removeAllObjects];
}

- (UIColor *)colorAtUser:(QBUUser *)user {
	NSAssert(self.users.count > 0, @"No users");
	
	CGFloat hue = ( (float)[self.users indexOfObject:user] / (float)self.users.count );  //  0.0 to 1.0
	CGFloat saturation = 1.0;
	CGFloat brightness = 1.0;

	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
