//
//  ChatManager.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ChatManager.h"
#import "UsersDataSource.h"

const NSTimeInterval kChatPresenceTimeInterval = 45;

@interface ChatManager ()

<QBChatDelegate>

@property (copy, nonatomic) void(^chatLoginCompletionBlock)(BOOL error);
@property (strong, nonatomic) QBRTCTimer *presenceTimer;

@end

@implementation ChatManager

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - Login / Logout

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL error))completion {

    [QBChat.instance addDelegate:self];
    
    if (QBChat.instance.isConnected) {
        completion(NO);
        return;
    }
    
    self.chatLoginCompletionBlock = completion;
    [QBChat.instance connectWithUser:user];
}

- (void)logOut {
    
    [self.presenceTimer invalidate];
    self.presenceTimer = nil;
    
    if ([QBChat.instance isConnected]) {
        [QBChat.instance disconnect];
    }
}

#pragma mark - QBChatDelegate

- (void)chatDidNotLogin {
    
    if (self.chatLoginCompletionBlock) {
        
        self.chatLoginCompletionBlock(YES);
        self.chatLoginCompletionBlock = nil;
    }
}

- (void)chatDidAccidentallyDisconnect {
    
	if (self.chatLoginCompletionBlock) {
        
		self.chatLoginCompletionBlock(YES);
		self.chatLoginCompletionBlock = nil;
	}
}

- (void)chatDidNotConnectWithError:(NSError *)error {
    
	if (self.chatLoginCompletionBlock) {
        
		self.chatLoginCompletionBlock(YES);
		self.chatLoginCompletionBlock = nil;
	}
}

- (void)chatDidFailWithStreamError:(NSError *)error {
    
    if (self.chatLoginCompletionBlock) {
        
        self.chatLoginCompletionBlock(YES);
        self.chatLoginCompletionBlock = nil;
    }
}

- (void)chatDidLogin {
    
    [[QBChat instance] sendPresence];
    __weak __typeof(self)weakSelf = self;
    
    self.presenceTimer = [[QBRTCTimer alloc] initWithTimeInterval:kChatPresenceTimeInterval
                                                           repeat:YES
                                                            queue:dispatch_get_main_queue()
                                                       completion:^{
         [[QBChat instance] sendPresence];
                                                           
    } expiration:^{
        
        if ([QBChat.instance isConnected]) {
            [QBChat.instance disconnect];
        }
        
        [weakSelf.presenceTimer invalidate];
        weakSelf.presenceTimer = nil;
    }];
    
    self.presenceTimer.label = @"Chat presence timer";
    
    if (self.chatLoginCompletionBlock) {
        
        self.chatLoginCompletionBlock(NO);
        self.chatLoginCompletionBlock = nil;
    }
}

@end
