//
//  QMChatService+Bolts.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 12/26/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatService.h"

#define kQMLoadedAllMessages @1
static NSString* const kQMChatServiceDomain = @"com.q-municate.chatservice";

@interface QMChatService()

@property (strong, nonatomic) QBMulticastDelegate <QMChatServiceDelegate, QMChatConnectionDelegate> *multicastDelegate;
@property (weak, nonatomic)   BFTask* loadEarlierMessagesTask;
@property (strong, nonatomic) NSMutableDictionary *loadedAllMessages;

@end

@implementation QMChatService (Bolts)

#pragma mark - Chat connection

- (BFTask *)connect {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    if (!self.serviceManager.isAuthorized) {
        [source setError:[NSError errorWithDomain:kQMChatServiceDomain
                                             code:-1000
                                         userInfo:@{NSLocalizedRecoverySuggestionErrorKey : @"You are not authorized in REST."}]];
        return source.task;
    }
    
    if ([QBChat instance].isConnected) {
        [source setResult:nil];
    }
    else {
        [QBSettings setAutoReconnectEnabled:YES];
        
        QBUUser *user = self.serviceManager.currentUser;
        [[QBChat instance] connectWithUser:user completion:^(NSError *error) {
            //
            if (error != nil) {
                [source setError:error];
            } else {
                [source setResult:nil];
            }
        }];
    }

    return source.task;
}

- (BFTask *)disconnect {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self disconnectWithCompletionBlock:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

#pragma mark - chat dialog handling

- (BFTask *)joinToGroupDialog:(QBChatDialog *)dialog {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self joinToGroupDialog:dialog completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)allDialogsWithPageLimit:(NSUInteger)limit extendedRequest:(NSDictionary *)extendedRequest iterationBlock:(void (^)(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsers, BOOL *stop))interationBlock {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self allDialogsWithPageLimit:limit extendedRequest:extendedRequest iterationBlock:interationBlock completion:^(QBResponse *response) {
        //
        if (response.success) {
            [source setResult:nil];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

#pragma mark Chat dialog creation

- (BFTask *)createPrivateChatDialogWithOpponent:(QBUUser *)opponent {
    
    return [self createPrivateChatDialogWithOpponentID:opponent.ID];
}

- (BFTask *)createGroupChatDialogWithName:(NSString *)name photo:(NSString *)photo occupants:(NSArray *)occupants {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self createGroupChatDialogWithName:name photo:photo occupants:occupants completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        if (response.success) {
            [source setResult:createdDialog];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

- (BFTask *)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self createPrivateChatDialogWithOpponentID:opponentID completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        if (createdDialog != nil) {
            [source setResult:createdDialog];
        } else if (response.error != nil) {
            [source setError:response.error.error];
        } else {
            NSAssert(nil, @"Need to update this case");
        }
    }];
    
    return source.task;
}

#pragma mark - Edit dialog methods

- (BFTask *)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self changeDialogName:dialogName forChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            [source setResult:updatedDialog];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

- (BFTask *)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self changeDialogAvatar:avatarPublicUrl forChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            [source setResult:updatedDialog];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

- (BFTask *)joinOccupantsWithIDs:(NSArray *)ids toChatDialog:(QBChatDialog *)chatDialog {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self joinOccupantsWithIDs:ids toChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            [source setResult:updatedDialog];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

- (BFTask *)deleteDialogWithID:(NSString *)dialogID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self deleteDialogWithID:dialogID completion:^(QBResponse *response) {
        //
        if (response.success) {
            [source setResult:nil];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

#pragma mark Messages loading

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self messagesWithChatDialogID:chatDialogID completion:^(QBResponse *response, NSArray *messages) {
        //
        if (response.success) {
            [source setResult:messages];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

- (BFTask *)loadEarlierMessagesWithChatDialogID:(NSString *)chatDialogID {
    
    if ([self.loadedAllMessages[chatDialogID] isEqualToNumber: kQMLoadedAllMessages]) return [BFTask taskWithResult:@[]];
    
    if (self.loadEarlierMessagesTask == nil) {
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        QBChatMessage *oldestMessage = [self.messagesMemoryStorage oldestMessageForDialogID:chatDialogID];
        
        if (oldestMessage == nil) return [BFTask taskWithResult:@[]];
        
        NSString *oldestMessageDate = [NSString stringWithFormat:@"%ld", (NSUInteger)[oldestMessage.dateSent timeIntervalSince1970]];
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:self.chatMessagesPerPage];
        
        NSDictionary* parameters = @{
                                     @"date_sent[lt]" : oldestMessageDate,
                                     @"sort_desc"     : @"date_sent"
                                     };
        
        
        @weakify(self);
        [QBRequest messagesWithDialogID:chatDialogID extendedRequest:parameters forPage:page successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
            @strongify(self);
            
            if ([messages count] < self.chatMessagesPerPage) {
                self.loadedAllMessages[chatDialogID] = kQMLoadedAllMessages;
            }
            
            if ([messages count] > 0) {
                
                [self.messagesMemoryStorage addMessages:messages forDialogID:chatDialogID];
                
                if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                    [self.multicastDelegate chatService:self didAddMessagesToMemoryStorage:messages forDialogID:chatDialogID];
                }
            }
            
            [source setResult:[[messages reverseObjectEnumerator] allObjects]];
            
        } errorBlock:^(QBResponse *response) {
            @strongify(self);
            
            // case where we may have deleted dialog from another device
            if( response.status != QBResponseStatusCodeNotFound ) {
                [self.serviceManager handleErrorResponse:response];
            }
            
            [source setError:response.error.error];
        }];
        
        self.loadEarlierMessagesTask = source.task;
        return self.loadEarlierMessagesTask;
    }
    
    return [BFTask taskWithResult:@[]];
}

#pragma mark - chat dialog fetching

- (BFTask *)fetchDialogWithID:(NSString *)dialogID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self fetchDialogWithID:dialogID completion:^(QBChatDialog *dialog) {
        //
        [source setResult:dialog];
    }];
    
    return source.task;
}

- (BFTask *)loadDialogWithID:(NSString *)dialogID {
    
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:1 skip:0];
    NSMutableDictionary *extendedRequest = @{@"_id":dialogID}.mutableCopy;
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        @strongify(self);
        if ([dialogObjects firstObject] != nil) {
            [self.dialogsMemoryStorage addChatDialog:[dialogObjects firstObject] andJoin:YES completion:nil];
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didAddChatDialogToMemoryStorage:[dialogObjects firstObject]];
            }
        }
        
        [source setResult:[dialogObjects firstObject]];
    } errorBlock:^(QBResponse *response) {
        @strongify(self);
        [self.serviceManager handleErrorResponse:response];
        [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)fetchDialogsUpdatedFromDate:(NSDate *)date andPageLimit:(NSUInteger)limit iterationBlock:(void (^)(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsers, BOOL *stop))iteration {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self fetchDialogsUpdatedFromDate:date andPageLimit:limit iterationBlock:iteration completionBlock:^(QBResponse *response) {
        //
        if (response.success) {
            [source setResult:nil];
        } else {
            [source setError:response.error.error];
        }
    }];
    
    return source.task;
}

#pragma mark - notifications

- (BFTask *)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog toUsersIDs:(NSArray *)usersIDs {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:usersIDs completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendMessageAboutAcceptingContactRequest:(BOOL)accept toOpponentID:(NSUInteger)opponentID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendMessageAboutAcceptingContactRequest:accept toOpponentID:opponentID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendNotificationMessageAboutAddingOccupants:(NSArray *)occupantsIDs toDialog:(QBChatDialog *)chatDialog withNotificationText:(NSString *)notificationText {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:chatDialog withNotificationText:notificationText completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog withNotificationText:(NSString *)notificationText {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:notificationText completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog withNotificationText:(NSString *)notificationText {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendNotificationMessageAboutChangingDialogPhoto:chatDialog withNotificationText:notificationText completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog withNotificationText:(NSString *)notificationText {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendNotificationMessageAboutChangingDialogName:chatDialog withNotificationText:notificationText completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

#pragma mark - Message sending

- (BFTask *)sendMessage:(QBChatMessage *)message toDialogID:(NSString *)dialogID saveToHistory:(BOOL)saveToHistory saveToStorage:(BOOL)saveToStorage {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendMessage:message toDialogID:dialogID saveToHistory:saveToHistory saveToStorage:saveToStorage completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog saveToHistory:(BOOL)saveToHistory saveToStorage:(BOOL)saveToStorage {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendMessage:message toDialog:dialog saveToHistory:saveToHistory saveToStorage:saveToStorage completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)sendAttachmentMessage:(QBChatMessage *)attachmentMessage toDialog:(QBChatDialog *)dialog withAttachmentImage:(UIImage *)image {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self sendAttachmentMessage:attachmentMessage toDialog:dialog withAttachmentImage:image completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

#pragma mark - Message marking

- (BFTask *)markMessageAsDelivered:(QBChatMessage *)message {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self markMessageAsDelivered:message completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)markMessagesAsDelivered:(NSArray *)messages {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self markMessagesAsDelivered:messages completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)readMessage:(QBChatMessage *)message {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self readMessage:message completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self readMessages:messages forDialogID:dialogID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

@end
