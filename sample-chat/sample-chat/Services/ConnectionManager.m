//
//  ConnectionManager.m
//  Sample-chat
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ConnectionManager.h"
#import "QBServiceManager.h"
#import "StorageManager.h"

@interface ConnectionManager()

@property (copy, nonatomic) void(^chatLoginCompletionBlock)(BOOL success, NSString *errorMessage);
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
			[StorageManager.instance reset];
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

@end

@implementation QBUUser (ConnectionManager)

- (NSUInteger)index {
	NSUInteger idx = [QBServiceManager.instance.usersService indexOfUser:self];
	return idx;
}

- (UIColor *)color {
	UIColor *color = [QBServiceManager.instance.usersService colorForUser:self];
	return color;
}

@end
