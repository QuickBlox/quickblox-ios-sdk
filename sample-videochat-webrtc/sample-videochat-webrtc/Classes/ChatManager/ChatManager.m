//
//  ChatManager.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ChatManager.h"
#import "UsersDataSourceProtocol.h"
#import "Settings.h"

const NSTimeInterval kChatPresenceTimeInterval = 45;

@interface ChatManager ()

<QBChatDelegate>

@property (copy, nonatomic) void(^chatLoginCompletionBlock)(BOOL error);
@property (copy, nonatomic) dispatch_block_t chatDisconnectedBlock;
@property (copy, nonatomic) dispatch_block_t chatReconnectedBlock;
@property (strong, nonatomic) QBRTCTimer *presenceTimer;

@end

@implementation ChatManager

#pragma mark - Login / Logout

- (void)setHasActiveCall:(BOOL)hasActiveCall {
	if (_hasActiveCall != hasActiveCall) {
		_hasActiveCall = hasActiveCall;
		
		if (!_hasActiveCall) {
			[self disconnectIfNeededInBackground];
		}
	}
}

- (void)disconnectIfNeededInBackground {
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground && !self.hasActiveCall && [[QBChat instance] isConnected]) {
		[[QBChat instance] disconnectWithCompletionBlock:nil];
	}
}


@end
