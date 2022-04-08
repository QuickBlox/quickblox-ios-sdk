//
//  ChatManager+InfoMessages.m
//  sample-chat
//
//  Created by Injoit on 11.01.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ChatManager+InfoMessages.h"
#import "QBUUser+Chat.h"
#import "QBChatMessage+Chat.h"

@implementation ChatManager (InfoMessages)
- (void)sendLeave:(QBChatDialog *)dialog completionBlock:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    NSString *message = [NSString stringWithFormat:@"%@ %@", currentUser.fullName, @"has left"];
    QBChatMessage *chatMessage = [self configureChatMessage:message
                                                   toDialog:dialog
                                                currentUser:currentUser];
    chatMessage.isNotificationMessageTypeLeave = YES;
    [self sendChatMessage:chatMessage toDialog:dialog completionBlock:^(NSError * _Nullable error) {
        completion(error);
    }];
}

- (void)sendCreateToDialog:(QBChatDialog *)dialog
           completionBlock:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    NSPredicate *predicateUser = [NSPredicate predicateWithFormat:@"SELF != %@", @(currentUser.ID)];
    NSArray<NSNumber *> *usersIDs = [dialog.occupantIDs filteredArrayUsingPredicate:predicateUser];
    NSString *message = [self messageTextWithChatName:dialog.name];
    QBChatMessage *chatMessage = [self configureChatMessage:message
                                                   toDialog:dialog
                                                currentUser:currentUser];
    chatMessage.isNotificationMessageTypeCreate = YES;
    [self sendChatMessage:chatMessage toDialog:dialog completionBlock:^(NSError * _Nullable error) {
        completion(error);
    }];
    QBChatMessage *systemMessage = [self configureSystemMessage:message
                                                       toDialog:dialog
                                                    currentUser:currentUser];
    systemMessage.isNotificationMessageTypeCreate = YES;
    [self sendSystemMessage:systemMessage toUsers:usersIDs];
}

- (void)sendAdd:(NSArray<NSNumber *> *)usersIDs
       toDialog:(QBChatDialog *)dialog completionBlock:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    NSArray<QBUUser *> *users = [self.storage usersWithIDs:usersIDs];
    NSString *IDs = [usersIDs componentsJoinedByString:@","];
    NSString *message = [self messageTextWithUsers:users];
    QBChatMessage *chatMessage = [self configureChatMessage:message
                                                   toDialog:dialog
                                                currentUser:currentUser];
    chatMessage.isNotificationMessageTypeAdding = YES;
    chatMessage.customParameters[@"new_occupants_ids"] = [NSString stringWithFormat:@"%@", IDs];
    
    QBChatMessage *systemMessage = [self configureSystemMessage:message
                                                       toDialog:dialog
                                                    currentUser:currentUser];
    systemMessage.isNotificationMessageTypeAdding = YES;
    
    [self sendChatMessage:chatMessage toDialog:dialog completionBlock:^(NSError * _Nullable error) {
        if (error) {
            Log(error.localizedDescription);
        }
        completion(error);
        [self sendSystemMessage:systemMessage toUsers:usersIDs.copy];
    }];
}

- (void)sendDraftMessages {
    if (!self.draftMessages.count)  {
        return;
    }
    NSArray *messages = self.draftMessages.allObjects;
    __weak typeof(self)weakSelf = self;
    for (QBChatMessage *message in messages) {
        BOOL isSystemMessage = message.dialogID.length;
        // Handling unsent System Messages
        if (isSystemMessage) {
            [QBChat.instance sendSystemMessage:message completion:^(NSError * _Nullable error) {
                __typeof(weakSelf)strongSelf = weakSelf;
                if (error) {
                    Log(error.localizedDescription);
                } else {
                    [strongSelf.draftMessages removeObject:message];
                }
            }];
            continue;
        }
        // Handling unsent Chat Messages
        QBChatDialog *dialog = [self.storage dialogWithID:message.dialogID];
        if (!dialog) {
            continue;
        }
        [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
            __typeof(weakSelf)strongSelf = weakSelf;
            if (error) {
                Log(error.localizedDescription);
            } else {
                [strongSelf.draftMessages removeObject:message];
            }
        }];
    }
}

// MARK: - Internal Methods
- (NSString *)messageTextWithUsers:(NSArray<QBUUser *> *)users {
    Profile *profile = [[Profile alloc] init];
    NSString *message = [NSString stringWithFormat:@"%@ %@ ", profile.fullName, @"added"];
    for (QBUUser *user in users) {
        message = [NSString stringWithFormat:@"%@%@,", message, user.name];
    }
    message = [message substringToIndex:message.length - 1];
    return message;
}

- (NSString *)messageTextWithChatName:(NSString *)chatName {
    Profile *profile = [[Profile alloc] init];
    return [NSString stringWithFormat:@"%@ %@ \"%@\"",
            profile.fullName, @"created the group chat", chatName];
}

- (QBChatMessage *)configureChatMessage:(NSString *)text
                               toDialog:(QBChatDialog *)dialog
                            currentUser:(Profile *)currentUser {
    QBChatMessage *chatMessage = [[QBChatMessage alloc] init];
    chatMessage.senderID = currentUser.ID;
    chatMessage.dialogID = dialog.ID;
    chatMessage.deliveredIDs = @[@(currentUser.ID)];
    chatMessage.readIDs = @[@(currentUser.ID)];
    chatMessage.text = text;
    chatMessage.markable = YES;
    chatMessage.dateSent = NSDate.now;
    chatMessage.customParameters[@"save_to_history"] = @"1";
    return chatMessage;
}

- (QBChatMessage *)configureSystemMessage:(NSString *)text
                                 toDialog:(QBChatDialog *)dialog
                              currentUser:(Profile *)currentUser {
    QBChatMessage *systemMessage = [[QBChatMessage alloc] init];
    systemMessage.senderID = currentUser.ID;
    systemMessage.markable = NO;
    systemMessage.text = text;
    systemMessage.dateSent = NSDate.now;
    systemMessage.customParameters[@"dialog_id"] = dialog.ID;
    return systemMessage;
}

- (void)sendChatMessage:(QBChatMessage *)chatMessage
               toDialog:(QBChatDialog *)dialog
        completionBlock:(nullable QBChatCompletionBlock)completion {
    [dialog sendMessage:chatMessage completionBlock:^(NSError * _Nullable error) {
        if (error) {
            [self.draftMessages addObject:chatMessage];
        }
        completion(error);
    }];
}

- (void)sendSystemMessage:(QBChatMessage *)systemMessage toUsers:(NSArray<NSNumber *> *)users {
    for (NSNumber *userID in users) {
        systemMessage.recipientID = userID.unsignedIntegerValue;
        [QBChat.instance sendSystemMessage:systemMessage completion:^(NSError * _Nullable error) {
            if (error) {
                [self.draftMessages addObject:systemMessage];
            }
        }];
    }
}

@end
