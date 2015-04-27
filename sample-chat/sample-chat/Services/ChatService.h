//
//  ChatService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatServiceDelegate <NSObject>
- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message;
- (BOOL)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID;
@end

@interface ChatService : NSObject

@property (weak) id<ChatServiceDelegate> delegate;

+ (instancetype)instance;

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock;
- (void)logout;

- (void)sendMessage:(QBChatMessage *)message;
- (void)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock;
- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom;

- (void)joinRoom:(QBChatRoom *)room completionBlock:(void(^)(QBChatRoom *))completionBlock;
- (void)leaveRoom:(QBChatRoom *)room;

@end
