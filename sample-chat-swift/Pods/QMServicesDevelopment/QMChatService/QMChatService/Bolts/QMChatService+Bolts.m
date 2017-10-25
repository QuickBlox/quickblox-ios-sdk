//
//  QMChatService+Bolts.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 12/26/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatService.h"

#import "QMSLog.h"

#define kQMLoadedAllMessages @1

static NSString *const kQMChatServiceDomain = @"com.q-municate.chatservice";

@interface QMChatService()

//@property (assign, nonatomic, readwrite) QMChatConnectionState chatConnectionState;
@property (strong, nonatomic) QBMulticastDelegate <QMChatServiceDelegate, QMChatConnectionDelegate> *multicastDelegate;
@property (weak, nonatomic) BFTask* loadEarlierMessagesTask;
@property (strong, nonatomic) NSMutableDictionary *loadedAllMessages;

@end

@implementation QMChatService (Bolts)

//MARK: - Chat connection

- (BFTask *)connectWithUserID:(NSUInteger)userID password:(NSString *)password {
    
    if ([QBChat instance].isConnected) {
        return [BFTask taskWithResult:nil];
    }
    
    if (password == nil) {
        
        NSError *error =
        [NSError errorWithDomain:kQMChatServiceDomain
                            code:-10000
                        userInfo:
         @{
           NSLocalizedRecoverySuggestionErrorKey : @"connectWithUserID:password - password == nil"
           }];
        
        return [BFTask taskWithError:error];
    }
    
    if (userID == 0) {
        
        NSError *error =
        [NSError errorWithDomain:kQMChatServiceDomain
                            code:-10000
                        userInfo:@
         {
             NSLocalizedRecoverySuggestionErrorKey : @"connectWithUserID:password - userID == 0"
         }];
        
        return [BFTask taskWithError:error];
    }
    
    [QBSettings setAutoReconnectEnabled:YES];
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        if ([self.multicastDelegate
             respondsToSelector:@selector(chatServiceChatHasStartedConnecting:)]) {
            
            [self.multicastDelegate chatServiceChatHasStartedConnecting:self];
        }
        QBUUser *user = [QBUUser user];
        user.ID = userID;
        user.password = password;
        
        [[QBChat instance] connectWithUser:user
                                completion:^(NSError *error) {
                                    if (error) {
                                        [source setError:error];
                                    }
                                    else {
                                        [source setResult:nil];
                                    }
                                }];
    });
}

- (BFTask *)connect {
    
    QBUUser *user = self.serviceManager.currentUser;
    return [self connectWithUserID:user.ID password:user.password];
}

- (BFTask *)disconnect {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self disconnectWithCompletionBlock:^(NSError *error) {
            
            if (error != nil) {
                
                [source setError:error];
            }
            else {
                
                [source setResult:nil];
            }
        }];
    });
}

//MARK: - Chat dialog handling

- (BFTask *)joinToGroupDialog:(QBChatDialog *)dialog {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self joinToGroupDialog:dialog completion:^(NSError *error) {
            
            if (error != nil) {
                [source setError:error];
            }
            else {
                [source setResult:nil];
            }
        }];
    });
}

- (BFTask *)allDialogsWithPageLimit:(NSUInteger)limit
                    extendedRequest:(NSDictionary *)extendedRequest
                     iterationBlock:(void(^)(
                                             QBResponse *response,
                                             NSArray<QBChatDialog *> *dialogObjects,
                                             NSSet<NSNumber *> *dialogsUsersIDs,
                                             BOOL *stop))iterationBlock {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self allDialogsWithPageLimit:limit
                      extendedRequest:extendedRequest
                       iterationBlock:iterationBlock
                           completion:^(QBResponse *response)
         {
             if (response.success) {
                 
                 [source setResult:nil];
             }
             else {
                 
                 [source setError:response.error.error];
             }
         }];
    });
}

//MARK: Chat dialog creation

- (BFTask *)createPrivateChatDialogWithOpponent:(QBUUser *)opponent {
    
    return [self createPrivateChatDialogWithOpponentID:opponent.ID];
}

- (BFTask *)createGroupChatDialogWithName:(NSString *)name
                                    photo:(NSString *)photo
                                occupants:(NSArray *)occupants {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self createGroupChatDialogWithName:name
                                      photo:photo
                                  occupants:occupants
                                 completion:^(QBResponse *response,
                                              QBChatDialog *createdDialog)
         {
             if (response.success) {
                 
                 [source setResult:createdDialog];
             }
             else {
                 
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self createPrivateChatDialogWithOpponentID:opponentID
                                         completion:^(QBResponse *response,
                                                      QBChatDialog *createdDialog)
         {
             if (createdDialog) {
                 [source setResult:createdDialog];
             }
             else if (response.error) {
                 [source setError:response.error.error];
             }
             else {
                 
                 NSError *error =
                 [[NSError alloc] initWithDomain:kQMChatServiceDomain
                                            code:-10001
                                        userInfo:@
                  {
                      NSLocalizedRecoverySuggestionErrorKey :
                      @"Create private chat - error"
                  }];
                 
                 [source setError:error];
                 
             }
         }];
    });
}

//MARK: - Edit dialog methods

- (BFTask *)changeDialogName:(NSString *)dialogName
               forChatDialog:(QBChatDialog *)chatDialog {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self changeDialogName:dialogName
                 forChatDialog:chatDialog
                    completion:^(QBResponse *response,
                                 QBChatDialog *updatedDialog)
         {
             if (response.success) {
                 [source setResult:updatedDialog];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)changeDialogAvatar:(NSString *)avatarPublicUrl
                 forChatDialog:(QBChatDialog *)chatDialog {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self changeDialogAvatar:avatarPublicUrl
                   forChatDialog:chatDialog
                      completion:^(QBResponse *response,
                                   QBChatDialog *updatedDialog)
         {
             if (response.success) {
                 [source setResult:updatedDialog];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)joinOccupantsWithIDs:(NSArray *)ids
                    toChatDialog:(QBChatDialog *)chatDialog {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self joinOccupantsWithIDs:ids
                      toChatDialog:chatDialog
                        completion:^(QBResponse *response,
                                     QBChatDialog *updatedDialog)
         {
             if (response.success) {
                 [source setResult:updatedDialog];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)deleteDialogWithID:(NSString *)dialogID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self deleteDialogWithID:dialogID
                      completion:^(QBResponse *response)
         {
             if (response.success) {
                 [source setResult:nil];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

//MARK: Messages loading

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self messagesWithChatDialogID:chatDialogID
                            completion:^(QBResponse *response,
                                         NSArray<QBChatMessage *> *messages)
         {
             if (response.success) {
                 [source setResult:messages];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID
                     extendedRequest:(NSDictionary *)extendedParameters {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self messagesWithChatDialogID:chatDialogID
                       extendedRequest:extendedParameters
                            completion:^(QBResponse *response,
                                         NSArray<QBChatMessage *> *messages)
         {
             if (response.success) {
                 [source setResult:messages];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID
                      iterationBlock:(void (^)(QBResponse *response,
                                               NSArray *messages,
                                               BOOL *stop))iterationBlock {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self messagesWithChatDialogID:chatDialogID
                        iterationBlock:iterationBlock
                            completion:^(QBResponse *response, NSArray *messages)
         {
             if (response.success) {
                 [source setResult:messages];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID
                     extendedRequest:(NSDictionary *)extendedParameters
                      iterationBlock:(void (^)(QBResponse *response,
                                               NSArray *messages,
                                               BOOL *stop))iterationBlock {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self messagesWithChatDialogID:chatDialogID
                       extendedRequest:extendedParameters
                        iterationBlock:iterationBlock
                            completion:^(QBResponse *response, NSArray *messages)
         {
             if (response.success) {
                 [source setResult:messages];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

- (BFTask *)loadEarlierMessagesWithChatDialogID:(NSString *)chatDialogID {
    
    if ([self.loadedAllMessages[chatDialogID] isEqualToNumber: kQMLoadedAllMessages]) {
        return [BFTask taskWithResult:@[]];
    }
    
    if (self.loadEarlierMessagesTask == nil) {
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        QBChatMessage *oldestMessage = [self.messagesMemoryStorage oldestMessageForDialogID:chatDialogID];
        
        if (oldestMessage == nil) {
            return [BFTask taskWithResult:@[]];
        }
        
        NSString *oldestMessageDate = [NSString stringWithFormat:@"%tu", (NSUInteger)[oldestMessage.dateSent timeIntervalSince1970]];
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:self.chatMessagesPerPage];
        
        NSDictionary *parameters = @{
                                     @"date_sent[lte]" : oldestMessageDate,
                                     @"sort_desc" : @"date_sent",
                                     @"_id[lt]" : oldestMessage.ID,
                                     };
        
        [QBRequest messagesWithDialogID:chatDialogID
                        extendedRequest:parameters
                                forPage:page
                           successBlock:^(QBResponse *response,
                                          NSArray *messages,
                                          QBResponsePage *page)
         {
             if ([messages count] < self.chatMessagesPerPage) {
                 
                 self.loadedAllMessages[chatDialogID] = kQMLoadedAllMessages;
             }
             
             if ([messages count] > 0) {
                 
                 [self.messagesMemoryStorage addMessages:messages
                                             forDialogID:chatDialogID];
                 
                 if ([self.multicastDelegate
                      respondsToSelector:@selector(chatService:
                                                   didAddMessagesToMemoryStorage:
                                                   forDialogID:)]) {
                          
                          [self.multicastDelegate chatService:self
                                didAddMessagesToMemoryStorage:messages
                                                  forDialogID:chatDialogID];
                      }
             }
             
             [source setResult:[[messages reverseObjectEnumerator] allObjects]];
             
         } errorBlock:^(QBResponse *response) {
             // case where we may have deleted dialog from another device
             if (response.status != QBResponseStatusCodeNotFound) {
                 [self.serviceManager handleErrorResponse:response];
             }
             
             [source setError:response.error.error];
         }];
        
        self.loadEarlierMessagesTask = source.task;
        return self.loadEarlierMessagesTask;
    }
    
    return [BFTask taskWithResult:@[]];
}

//MARK: - chat dialog fetching

- (BFTask *)fetchDialogWithID:(NSString *)dialogID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self fetchDialogWithID:dialogID
                     completion:^(QBChatDialog *dialog)
         {
             [source setResult:dialog];
         }];
    });
}


- (BFTask *)loadDialogWithID:(NSString *)dialogID {
    
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:1 skip:0];
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    extendedRequest[@"_id"] = dialogID;
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response,
                                    NSArray *dialogObjects,
                                    NSSet *dialogsUsersIDs,
                                    QBResponsePage *page)
         {
             QBChatDialog *dialog = dialogObjects.firstObject;
             
             if (dialog) {
                 
                 __weak __typeof(self)weakSelf = self;
                 [self.dialogsMemoryStorage addChatDialog:dialog
                                                  andJoin:YES
                                               completion:^(QBChatDialog *addedDialog,
                                                            NSError *error)
                  {
                      
                      if ([weakSelf.multicastDelegate
                           respondsToSelector:@selector(chatService:
                                                        didAddChatDialogToMemoryStorage:)]) {
                               
                               [weakSelf.multicastDelegate chatService:weakSelf
                                       didAddChatDialogToMemoryStorage:addedDialog];
                           }
                      
                      [source setResult:addedDialog];
                  }];
             }
             
         } errorBlock:^(QBResponse *response) {
             
             [self.serviceManager handleErrorResponse:response];
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)fetchDialogsUpdatedFromDate:(NSDate *)date
                           andPageLimit:(NSUInteger)limit
                         iterationBlock:(void(^)(QBResponse *response,
                                                 NSArray<QBChatDialog *> *dialogObjects,
                                                 NSSet<NSNumber *> *dialogsUsersIDs,
                                                 BOOL *stop))iterationBlock {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self fetchDialogsUpdatedFromDate:date
                             andPageLimit:limit
                           iterationBlock:iterationBlock
                          completionBlock:^(QBResponse *response)
         {
             if (response.success) {
                 [source setResult:nil];
             }
             else {
                 [source setError:response.error.error];
             }
         }];
    });
}

//MARK: - notifications

- (BFTask *)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                      toUsersIDs:(NSArray *)usersIDs
                                        withText:(NSString *)text {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendSystemMessageAboutAddingToDialog:chatDialog
                                        toUsersIDs:usersIDs
                                          withText:text
                                        completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                       toOpponentID:(NSUInteger)opponentID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendMessageAboutAcceptingContactRequest:accept
                                         toOpponentID:opponentID
                                           completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendNotificationMessageAboutAddingOccupants:(NSArray *)occupantsIDs
                                               toDialog:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendNotificationMessageAboutAddingOccupants:occupantsIDs
                                                 toDialog:chatDialog
                                     withNotificationText:notificationText
                                               completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                                 withNotificationText:(NSString *)notificationText {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendNotificationMessageAboutLeavingDialog:chatDialog
                                   withNotificationText:notificationText
                                             completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                       withNotificationText:(NSString *)notificationText {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendNotificationMessageAboutChangingDialogPhoto:chatDialog
                                         withNotificationText:notificationText
                                                   completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
    
}

- (BFTask *)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                      withNotificationText:(NSString *)notificationText {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendNotificationMessageAboutChangingDialogName:chatDialog
                                        withNotificationText:notificationText
                                                  completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

//MARK: - Message sending

- (BFTask *)sendMessage:(QBChatMessage *)message
                   type:(QMMessageType)type
               toDialog:(QBChatDialog *)dialog
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendMessage:message
                     type:type
                 toDialog:dialog
            saveToHistory:saveToHistory
            saveToStorage:saveToStorage
               completion:^(NSError *error)
         {
             if (error) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendMessage:(QBChatMessage *)message
             toDialogID:(NSString *)dialogID
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendMessage:message
               toDialogID:dialogID
            saveToHistory:saveToHistory
            saveToStorage:saveToStorage
               completion:^(NSError *error)
         {
             
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendMessage:(QBChatMessage *)message
               toDialog:(QBChatDialog *)dialog
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendMessage:message
                 toDialog:dialog
            saveToHistory:saveToHistory
            saveToStorage:saveToStorage
               completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

- (BFTask *)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                         toDialog:(QBChatDialog *)dialog
              withAttachmentImage:(UIImage *)image {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self sendAttachmentMessage:attachmentMessage
                           toDialog:dialog
                withAttachmentImage:image
                         completion:^(NSError *error) {
                             
                             if (error != nil) {
                                 [source setError:error];
                             }
                             else {
                                 [source setResult:nil];
                             }
                         }];
    });
}

//MARK: - Message marking

- (BFTask *)markMessageAsDelivered:(QBChatMessage *)message {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self markMessageAsDelivered:message completion:^(NSError *error) {
            
            if (error != nil) {
                [source setError:error];
            }
            else {
                [source setResult:nil];
            }
        }];
    });
}

- (BFTask *)markMessagesAsDelivered:(NSArray *)messages {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self markMessagesAsDelivered:messages completion:^(NSError *error) {
            
            if (error != nil) {
                [source setError:error];
            }
            else {
                [source setResult:nil];
            }
        }];
    });
}

- (BFTask *)readMessage:(QBChatMessage *)message {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self readMessage:message completion:^(NSError *error) {
            
            if (error != nil) {
                [source setError:error];
            }
            else {
                [source setResult:nil];
            }
        }];
    });
}

- (BFTask *)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self readMessages:messages forDialogID:dialogID
                completion:^(NSError *error)
         {
             if (error != nil) {
                 [source setError:error];
             }
             else {
                 [source setResult:nil];
             }
         }];
    });
}

@end
