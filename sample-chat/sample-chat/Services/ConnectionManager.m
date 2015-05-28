//
//  ConnectionManager.m
//  Sample-chat
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ConnectionManager.h"
#import "QBServiceManager.h"
#import "UsersDataSource.h"

const NSTimeInterval kChatPresenceTimeInterval = 45;

@interface ConnectionManager()

@property (copy, nonatomic) void(^chatLoginCompletionBlock)(BOOL success, NSString *errorMessage);
@property (strong, nonatomic) NSArray *dialogs;
@property (strong, nonatomic) UsersDataSource *usersDataSource;
@end

@implementation ConnectionManager

+ (instancetype)instance {
	
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (instancetype)init {
	self = [super init];
	if( self ) {
		self.usersDataSource = [[UsersDataSource alloc] init];
	}
	return self;
}
#pragma mark - Login / Logout

- (void)logInWithUser:(QBUUser *)user
		   completion:(void (^)(BOOL success, NSString *errorMessage))completion {
	
	__weak __typeof(self)weakSelf = self;
	[[QBServiceManager instance].authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
		
		if( response.error != nil ){
			completion(NO, response.error.error.localizedDescription);
			return;
		}
		if( QBServiceManager.instance.currentUser != nil ){
			[QBServiceManager.instance.chatService logoutChat];
			weakSelf.dialogs = nil;
		}
		
		[QBServiceManager.instance.chatService logIn:^(NSError *error) {
			completion(error == nil, error.localizedDescription);
		}];
		
	}];
}

- (void)logOut {
	
}

#pragma mark - QBChatDelegate

- (void)chatDidNotLogin {
	if (self.chatLoginCompletionBlock) {
		self.chatLoginCompletionBlock(NO, @"");
		self.chatLoginCompletionBlock = nil;
	}
}

- (void)chatDidFailWithError:(NSInteger)code {
	if (self.chatLoginCompletionBlock) {
		self.chatLoginCompletionBlock(NO, @"");
		self.chatLoginCompletionBlock = nil;
	}
}

- (void)chatDidLogin {
	if (self.chatLoginCompletionBlock) {
		self.chatLoginCompletionBlock(YES, @"");
		self.chatLoginCompletionBlock = nil;
	}
}

#pragma mark - Public

- (void)usersWithSuccessBlock:(void(^)(NSArray *users))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	
	NSString *const kTestUsersTableKey = @"test_users";
	NSString *const kUserFullNameKey = @"fullname";
	NSString *const kUserLoginKey = @"login";
	NSString *const kUserPasswordKey = @"password";
	
	if( self.usersDataSource.users != nil ){
		if( successBlock != nil ) {
			successBlock(self.usersDataSource.users);
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
		
		ConnectionManager.instance.usersDataSource.users = [users copy];
		
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

@end

@implementation QBUUser (ConnectionManager)

- (NSUInteger)index {
	NSUInteger idx = [ConnectionManager.instance.usersDataSource indexOfUser:self];
	return idx;
}

- (UIColor *)color {
	UIColor *color = [ConnectionManager.instance.usersDataSource colorForUser:self];
	return color;
}

@end
