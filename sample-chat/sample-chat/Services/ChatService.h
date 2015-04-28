//
//  ChatService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDialogUpdatedNotification @"kDialogUpdatedNotification"

@protocol ChatServiceDelegate <NSObject>
- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message;
- (BOOL)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID;
- (void)chatDidLogin;
@end

@interface ChatService : NSObject

@property (nonatomic, readonly) QBUUser *currentUser;

@property (weak) id<ChatServiceDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, strong) NSMutableDictionary *messages;

+ (instancetype)shared;

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock;
- (void)logout;

- (void)sendMessage:(QBChatMessage *)message;
- (void)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock;
- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom;

- (void)joinRoom:(QBChatRoom *)room completionBlock:(void(^)(QBChatRoom *))completionBlock;
- (void)leaveRoom:(QBChatRoom *)room;

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId;
- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId;
- (void)addMessage:(QBChatAbstractMessage *)message forDialogId:(NSString *)dialogId;

- (void)requestDialogsWithCompletionBlock:(void(^)())completionBlock;
- (void)requestDialogUpdateWithId:(NSString *)dialogId completionBlock:(void(^)())completionBlock;

@end
