//
//  PushMessagesManager.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 11/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "PushMessagesManager.h"
#import "UsersDataSource.h"
#import "SampleCore.h"

@implementation PushMessagesManager

- (void)registerForRemoteNotifications {
 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
	}
	else{
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
	}
#else
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

- (void)unsubscribeWithVendorID:(NSString *)vendorID successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	__weak __typeof(self)weakSelf = self;
	
	[QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:vendorID successBlock:^(QBResponse * _Nonnull response) {
		weakSelf.subscribed = NO;
		if (successBlock) {
			successBlock();
		}
	} errorBlock:^(QBError * _Nullable error) {
		if (error.error.code == -1011) { // subscription not found, 404
			weakSelf.subscribed = NO;
			if (successBlock) {
				successBlock();
			}
		} else{
			if (errorBlock) {
				errorBlock(error);
			}
		}
	}];
}

- (void)unsubscribeCurrentDeviceUDIDWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	
	NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	return [self unsubscribeWithVendorID:deviceIdentifier successBlock:successBlock errorBlock:errorBlock];
}

- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken user:(QBUUser *)user successBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBError *error))errorBlock {
	if (!deviceToken) {
		if (errorBlock) {
			errorBlock([QBError errorWithError:[NSError errorWithDomain:@"no device token" code:-1 userInfo:nil]]);
		}
		return;
	}
	
 
	QBMSubscription *subscription = [QBMSubscription subscription];
	subscription.notificationChannel = QBMNotificationChannelAPNS;
	subscription.deviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	subscription.deviceToken = deviceToken;
	
	NSParameterAssert(deviceToken);
	
	__weak __typeof(self)weakSelf = self;
	
	[QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
		weakSelf.subscribed = YES;
		
		if (successBlock) {
			successBlock();
		}
	} errorBlock:^(QBResponse *response) {
		if (errorBlock) {
			errorBlock(response.error);
		}
	}];
	
}

@end
