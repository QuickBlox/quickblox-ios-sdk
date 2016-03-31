//
//  PushMessagesManager.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 11/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushMessagesManager : NSObject

@property (nonatomic, assign, getter=isSubscribed) BOOL subscribed;

- (void)registerForRemoteNotifications;
- (void)unsubscribeWithVendorID:(NSString *)vendorID successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;
- (void)unsubscribeCurrentDeviceUDIDWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken user:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock;

@end
