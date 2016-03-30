//
//  SampleCoreManager.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 3/29/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "SampleCoreManager.h"
#import "SampleCore.h"

#import "PushMessagesManager.h"
#import "KeychainHelper.h"

#import "UsersDataSourceProtocol.h"
#import "UsersService.h"

static NSString *kVendorID = @"keychain_push_vendorID";
static NSString *kUserLogin = @"keychain_user_login";


@interface SampleCoreManager() <QBChatDelegate>
@property (nonatomic, copy) dispatch_block_t chatDisconnectedBlock;
@property (nonatomic, copy) dispatch_block_t chatReconnectedBlock;
@end

@implementation SampleCoreManager

+ (instancetype)instance {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}


#pragma mark Authorization

- (void)logInWithUserInREST:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void (^)(NSError *))errorBlock {
	
	if ([QBSession currentSession].currentUser.ID == user.ID) {
		if (successBlock) {
			successBlock();
		}
		return;
	}
	
	[QBRequest logInWithUserLogin:user.login password:user.password successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
		
		if (successBlock) {
			successBlock();
		}
		
	} errorBlock:^(QBResponse * _Nonnull response) {
		if (errorBlock) {
			errorBlock(response.error.error);
		}
	}];

}

- (void)connectToChatWithUser:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void (^)(NSError *))errorBlock chatDisconnectedBlock:(dispatch_block_t)chatDisconnectedBlock chatReconnectedBlock:(dispatch_block_t)chatReconnectedBlock {
	if (chatDisconnectedBlock) {
		self.chatDisconnectedBlock = chatDisconnectedBlock;
	}
	
	if (chatReconnectedBlock) {
		self.chatReconnectedBlock = chatReconnectedBlock;
	}
	
	if ([QBChat instance].currentUser.ID == user.ID) {
		if (successBlock) {
			successBlock();
		}
		return;
	}
	
	if ([[QBChat instance] isConnected]) {
		// if we connected with another user, firstly disconnect
		[[QBChat instance] disconnectWithCompletionBlock:nil];
	}

	[[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
		if (error) {
			if (errorBlock) {
				errorBlock(error);
			}
		} else {
			if (successBlock) {
				successBlock();
			}
		}
	}];
	
}

- (void)chatDidAccidentallyDisconnect {
	if (self.chatDisconnectedBlock) {
		self.chatDisconnectedBlock();
	}
}

- (void)chatDidReconnect {
	if (self.chatReconnectedBlock) {
		self.chatReconnectedBlock();
	}
}

#pragma mark Logout

- (void)accountLogoutWithUnsubscribingBlock:(dispatch_block_t)unsubscribingBlock successBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock {
	
	if ([QBSession currentSession].currentUser == nil) {
		if (errorBlock) {
			errorBlock();
			NSLog(@"Can not logout because not logined");
		}
		return;
	}
	
	[QBRequest deleteCurrentUserWithSuccessBlock:^(QBResponse * _Nonnull response) {
	
		if (unsubscribingBlock) {
			unsubscribingBlock();
		}
		
		[self unsubscribeCurrentDeviceUDIDWithSuccessBlock:^{
		
		
		dispatch_group_t logoutGroup = dispatch_group_create();
		// logout from REST
		dispatch_group_enter(logoutGroup);
		[self logoutFromRestWithSuccessBlock:^{
			dispatch_group_leave(logoutGroup);
		} errorBlock:^{
			dispatch_group_leave(logoutGroup);
		}];
		
		// disconnect from Chat if needed
		if ([[QBChat instance] isConnected]) {
			
			dispatch_group_enter(logoutGroup);
			[self disconnectFromChatWithSuccessBlock:^{
				dispatch_group_leave(logoutGroup);
			} errorBlock:^{
				dispatch_group_leave(logoutGroup);
			}];
		}
		
		dispatch_group_notify(logoutGroup, dispatch_get_main_queue(), ^{
			
			if (![[QBChat instance] isConnected] &&
				[[QBSession currentSession] currentUser] == nil) {
				if (successBlock) {
					successBlock();
				}
			}
			else {
				if (errorBlock) {
					errorBlock();
				}
			}
			
		});
	} errorBlock:^(QBError *error) {
		if (errorBlock) {
			errorBlock();
		}
	}];
	} errorBlock:^(QBResponse * _Nonnull response) {
		if (errorBlock) {
			errorBlock();
		}
	}];
}

- (void)logoutFromRestWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock {
	[QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
		
		[[SampleCore usersDataSource] clear];
		[SampleCore usersDataSource].currentUser = nil;
		
	} errorBlock:^(QBResponse * _Nonnull response) {
		if (errorBlock) {
			errorBlock();
		}
	}];
}

- (void)disconnectFromChatWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock {
	[[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
		if (error) {
			if (errorBlock) {
				errorBlock();
			}
		}
		else {
			if (successBlock) {
				successBlock();
			}
		}
	}];
}

#pragma mark Push

- (void)registerForRemoteNotifications {
	[[SampleCore pushMessagesManager] registerForRemoteNotifications];
}

- (void)registerCurrentUserForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	
	if (!deviceToken) {
		if (errorBlock) {
			errorBlock([QBError errorWithError:[NSError errorWithDomain:@"no device token" code:-1 userInfo:nil]]);
		}
		return;
	}
	
	dispatch_group_t unsubscribeGroup = dispatch_group_create();
	
	dispatch_group_enter(unsubscribeGroup);
	
	[self unsubscribeSavedUserFromPushNotificationsIfNeededWithSuccessBlock:^{
		dispatch_group_leave(unsubscribeGroup);
	} errorBlock:^(QBError *error) {
		dispatch_group_leave(unsubscribeGroup);
	}];
	
	dispatch_group_notify(unsubscribeGroup, dispatch_get_main_queue(), ^{
		
		QBUUser *currentUser = [SampleCore usersDataSource].currentUserWithDefaultPassword;
		
		[[SampleCore pushMessagesManager] registerForRemoteNotificationsWithDeviceToken:deviceToken user:currentUser successBlock:^{
			
			NSString *currentVendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
			
			[KeychainHelper saveKey:kVendorID data:currentVendorID];
			[KeychainHelper saveKey:kUserLogin data:currentUser.login];
			
		} errorBlock:errorBlock];
	});

}

- (void)unsubscribeSavedUserFromPushNotificationsIfNeededWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	id<UsersDataSourceProtocol> usd = [SampleCore usersDataSource];
	
	// currentUser is nil when NSUserDefaults is clear, e.g. after
	// re-install application
	QBUUser *currentUser = usd.currentUserWithDefaultPassword;
	
	// 1 Check if saved vendor ID equals current vendor id
	// If no – unsubscribe previous saved user
	
	// 2 Unsubscribe previous user if he preivously logged out without unsubscribing from push notifications
	
	NSString *currentVendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	NSString *savedVendorID = [KeychainHelper loadKey:kVendorID];
	
	NSString *savedUserLogin = [KeychainHelper loadKey:kUserLogin];
	
	if ([savedVendorID isEqualToString:currentVendorID] &&
		[currentUser.login isEqualToString:savedUserLogin]) {
		// VendorID has not changed
		if (successBlock) {
			successBlock();
		}
	}
	else {
		if (!savedUserLogin) {
			return;
		}
		QBUUser *previousUser = [QBUUser user];
		previousUser.login = savedUserLogin;
		previousUser.password = usd.defaultPassword;
		
		[self unsubscribeUserFromPushNotifications:previousUser vendorID:savedVendorID  successBlock:successBlock errorBlock:errorBlock];
	}
}

- (void)unsubscribeUserFromPushNotifications:(QBUUser *)user vendorID:(NSString *)vendorID successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	dispatch_group_t loginGroup = dispatch_group_create();
	
	// if user is not equal [[QBSession currentSession] currentUser], then we should login firstly
	if ([QBSession currentSession].currentUser.ID != user.ID) {
		[QBRequest logInWithUserLogin:user.login password:user.password successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
			dispatch_group_leave(loginGroup);
		} errorBlock:^(QBResponse * _Nonnull response) {
			dispatch_group_leave(loginGroup);
		}];
	}
	
	dispatch_group_notify(loginGroup, dispatch_get_main_queue(), ^{
		
		if ([QBSession currentSession].currentUser.ID != user.ID) {
			// unsuccessful login
			if (errorBlock) {
				errorBlock([QBError errorWithError:[NSError errorWithDomain:@"Can not login to unsubscribe after application re-install" code:-1 userInfo:nil]]);
			}
			return;
		}
		
		[[SampleCore pushMessagesManager] unsubscribeWithVendorID:vendorID successBlock:successBlock errorBlock:errorBlock];
		
	});
}

- (void)unsubscribeCurrentDeviceUDIDWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	
	void (^clearCache)() = ^void() {
		[KeychainHelper deleteKey:kVendorID];
		[KeychainHelper deleteKey:kUserLogin];
	};
	
	[[SampleCore pushMessagesManager] unsubscribeCurrentDeviceUDIDWithSuccessBlock:^{
		clearCache();
		if (successBlock) {
			successBlock();
		}
	} errorBlock:^(QBError * _Nullable error) {
		if (error.error.code == -1011) { // subscription not found, 404
			clearCache();
			if (successBlock) {
				successBlock();
			}
		}
		else {
			if (errorBlock) {
				errorBlock(error);
			}
		}
	}];
}

#pragma mark Users service

+ (void)downloadAndCacheUserIfNeeded:(NSNumber *)userID successBlock:(void (^)(QBUUser *))successBlock errorBlock:(void (^)(QBResponse *))errorBlock {
	id<UsersDataSourceProtocol> dataSource = [SampleCore usersDataSource];
	
	[QBRequest userWithID:userID.unsignedIntegerValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
		[dataSource addUser:user];
		if (successBlock) {
			successBlock(user);
		}
	} errorBlock:errorBlock];
}

+ (void)downloadAndCacheUsersWithTags:(NSArray *)tags successBlock:(dispatch_block_t)successBlock errorBlock:(void (^)(QBResponse *))errorBlock {
	
	[UsersService allUsersWithTags:tags perPageLimit:50 successBlock:^(NSArray *usersObjects) {
		[[SampleCore usersDataSource] loadUsersWithArray:usersObjects tags:tags];
		if (successBlock) {
			successBlock();
		}
	} errorBlock:errorBlock];
	
}

+ (void)allUsersWithTags:(NSArray *)tags perPageLimit:(NSUInteger)limit successBlock:(void (^)(NSArray *))successBlock errorBlock:(void (^)(QBResponse *))errorBlock {
	NSCParameterAssert(tags);
	
	[UsersService allUsersWithTags:tags perPageLimit:limit successBlock:successBlock errorBlock:errorBlock];
}

@end
