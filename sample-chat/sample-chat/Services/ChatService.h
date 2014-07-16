//
//  ChatService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationDidReceiveNewMessage @"kNotificationDidReceiveNewMessage"
#define kNotificationDidReceiveNewMessageFromRoom @"kNotificationDidReceiveNewMessageFromRoom"
#define kMessage @"kMessage"
#define kRoomJID @"kRoomJID"

@interface ChatService : NSObject

+ (instancetype)instance;

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock;

- (void)sendMessage:(QBChatMessage *)message;

- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom;
- (void)createOrJoinRoomWithName:(NSString *)roomName completionBlock:(void(^)(QBChatRoom *))completionBlock;
- (void)joinRoom:(QBChatRoom *)room completionBlock:(void(^)(QBChatRoom *))completionBlock;
- (void)leaveRoom:(QBChatRoom *)room;
- (void)requestRoomsWithCompletionBlock:(void(^)(NSArray *))completionBlock;

@end
