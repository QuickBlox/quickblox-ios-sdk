//
//  SampleCoreManager.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 3/29/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleCoreManager : NSObject

+ (instancetype)instance;


#pragma mark Authorization

- (void)logInWithUserInREST:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)connectToChatWithUser:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(NSError *error))errorBlock chatDisconnectedBlock:(dispatch_block_t)chatDisconnectedBlock chatReconnectedBlock:(dispatch_block_t)chatReconnectedBlock;

#pragma mark Logout

/**
 *  1 Delete current user
 *  2 Call unsubscribingBlock, then unsubscribe current device from pushes
 *  3 Logout from rest and clear cache
 *  4 Disconnect from chat
 */
- (void)accountLogoutWithUnsubscribingBlock:(dispatch_block_t)unsubscribingBlock successBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock;

/**
 *  Logout from REST and clear users data source
 */
- (void)logoutFromRestWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock;

/**
 *  Disconnect from Chat
 */
- (void)disconnectFromChatWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(dispatch_block_t)errorBlock;
#pragma mark Push notifications

- (void)registerForRemoteNotifications;
- (void)registerCurrentUserForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;

- (void)unsubscribeSavedUserFromPushNotificationsIfNeededWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;
- (void)unsubscribeUserFromPushNotifications:(QBUUser *)user vendorID:(NSString *)vendorID successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;
- (void)unsubscribeCurrentDeviceUDIDWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;

#pragma mark Users service

+ (void)downloadAndCacheUserIfNeeded:(NSNumber *)userID successBlock:(void (^)(QBUUser *))successBlock errorBlock:(void (^)(QBResponse *))errorBlock;

+ (void)allUsersWithTags:(NSArray *)tags perPageLimit:(NSUInteger)limit
			successBlock:(void(^)(NSArray *usersObjects))successBlock
			  errorBlock:(void(^)(QBResponse *response))errorBlock;
@end
