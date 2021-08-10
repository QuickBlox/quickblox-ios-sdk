//
//  ChatManager.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatManager.h"
#import <Quickblox/Quickblox.h>
#import "ChatStorage.h"
#import "Constants.h"
#import "Log.h"
#import "AppDelegate.h"
#import "ConnectionModule.h"
#import "Profile.h"

static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";
static NSUInteger const kMessagesLimitPerDialog = 30;
static NSUInteger const kUsersLimit = 100;
static NSUInteger const kErrorDomaimCode = -1000;

typedef void(^DialogsIterationHandler)(QBResponse *response, NSArray<QBChatDialog *> *objects , NSSet<NSNumber *> *usersIDs, Boolean stop);
typedef void(^DialogsPage)(QBResponsePage *page);
typedef void(^UsersPage)(QBGeneralResponsePage *page);

@interface ChatManager ()

@property (strong, nonatomic) ConnectionModule *connection;
@property (assign, nonatomic) BOOL onConnectStatus;

@end

@implementation ChatManager
- (ConnectionModule *)connection {
    if (_connection) {
        return _connection;
    }
    _connection = [[ConnectionModule alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    
    [_connection setOnStartAuthorization:^{
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerStartAuthorization:)]) {
            [weakSelf.connectionDelegate chatManagerStartAuthorization:weakSelf];
        }
        
        Log(@"[%@] [connection] On Start Authorization",  NSStringFromClass(weakSelf.class));
    }];
    
    [_connection setOnAuthorize:^{
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerAuthorize:)]) {
            [weakSelf.connectionDelegate chatManagerAuthorize:weakSelf];
        }
        Log(@"[%@] [connection] On Authorize",  NSStringFromClass(weakSelf.class));
    }];
    
    [_connection setOnAuthorizeFailed:^{
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerAuthorizeFailed:)]) {
            [weakSelf.connectionDelegate chatManagerAuthorizeFailed:weakSelf];
        }
        Log(@"[%@] [connection] On Authorize Failed",  NSStringFromClass(weakSelf.class));
        [weakSelf.connection deactivateAutomaticMode];
        
    }];
    
    [_connection setOnStartConnection:^{
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerStartConnection:)]) {
            [weakSelf.connectionDelegate chatManagerStartConnection:weakSelf];
        }
        Log(@"[%@] [connection] On Start Connection",  NSStringFromClass(weakSelf.class));
    }];
    
    [_connection setOnConnect:^{
        weakSelf.onConnectStatus = YES;
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerConnect:)]) {
            [weakSelf.connectionDelegate chatManagerConnect:weakSelf];
        }
        Log(@"[%@] [connection] On Connect",  NSStringFromClass(weakSelf.class));
    }];
    
    [_connection setOnDisconnect:^(BOOL lostNetwork) {
        weakSelf.onConnectStatus = NO;
        if ([weakSelf.connectionDelegate respondsToSelector:@selector(chatManagerDisconnect:withLostNetwork:)]) {
            [weakSelf.connectionDelegate chatManagerDisconnect:weakSelf withLostNetwork:lostNetwork ];
        }
        Log(@"[%@] [connection] On Disconnect",  NSStringFromClass(weakSelf.class));
    }];
    
    return _connection;
}

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _onConnectStatus = NO;
        self.storage = [[ChatStorage alloc] init];
    }
    return self;
}

//Shared Instance
+ (instancetype)instance {
    static ChatManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - Public Connection Methods
- (void)activateAutomaticMode {
    [self.connection activateAutomaticMode];
}

- (BOOL)onConnect {
   return self.onConnectStatus;
}

- (BOOL)tokenHasExpired {
   return [self.connection tokenHasExpired];
}

- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion {
    [self.connection breakConnectionWithCompletion:completion];
}

- (void)deactivateAutomaticMode {
    [self.connection deactivateAutomaticMode];
}

- (BOOL)isNetworkLost {
    return [self.connection isNetworkLost];
}

- (void)establishConnection {
    [self.connection establishConnection];
}

#pragma mark - Public Methods
- (void)updateStorage {
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    
    if (QBChat.instance.isConnected == NO) {
        if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
            [self.delegate chatManager:self didFailUpdateStorage:NSLocalizedString(@"SA_STR_NETWORK_ERROR", nil)];
        }
        return;
    }
    __block NSString *message;
    
    [self updateAllDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:nil completion:^(QBResponse *response) {
        if (response) {
            message = [self errorMessageWithResponse:response];
        }
        if (message) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:message];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
            }
        }
    }];
}

//MARK: - System Messages
- (void)sendStartConferenceMessage:(ConferenceInfo *)conferenceInfo completion:(QBChatCompletionBlock)completion {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    
    QBChatDialog *dialog = [self.storage dialogWithID:conferenceInfo.chatDialogID];
    
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.senderID = currentUserID;
    if ([conferenceInfo.callType isEqualToString: @"4"]) {
        message.text = @"Conference started";
        message.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeStartConference)];
    } else if ([conferenceInfo.callType isEqualToString: @"5"]) {
        message.text = @"Stream started";
        message.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeStartStream)];
    }
    message.customParameters[@"conference_id"] = conferenceInfo.conferenceID;
    message.deliveredIDs = @[@(currentUserID)];
    message.readIDs = @[@(currentUserID)];
    message.customParameters[@"save_to_history"] = @"1";
    message.dateSent = NSDate.now;

    // send system messages
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)sendLeaveMessage:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.senderID = currentUserID;
    message.text = text;
    message.deliveredIDs = @[@(currentUserID)];
    message.readIDs = @[@(currentUserID)];
    message.customParameters[@"save_to_history"] = @"1";
    message.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeLeave)];
    message.dateSent = NSDate.now;
    
    QBChatMessage *systemMessage = [[QBChatMessage alloc] init];
    systemMessage.senderID = currentUserID;
    systemMessage.text = text;
    systemMessage.deliveredIDs = @[@(currentUserID)];
    systemMessage.readIDs = @[@(currentUserID)];
    systemMessage.customParameters[@"dialog_id"] = dialog.ID;
    systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeLeave)];
    systemMessage.dateSent = NSDate.now;
    
    
    // send system messages
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (completion) {
            if (error) {
                completion(error);
                if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                    [self.delegate chatManager:self didFailUpdateStorage:@"Chat is not connected"];
                }
                return;
            } else
                completion(nil);
            for (NSNumber *occupantID in dialog.occupantIDs) {
                if (currentUserID == occupantID.integerValue) {
                    continue;
                }
                systemMessage.recipientID = occupantID.unsignedIntegerValue;
                [QBChat.instance sendSystemMessage:systemMessage completion:^(NSError * _Nullable error) {
                }];
            }
        }
    }];
}

- (void)sendAddingMessage:(NSString *)text
                   action:(DialogActionType)action
                withUsers:(NSArray<NSNumber *> *)usersIDs
                 toDialog:(QBChatDialog *)dialog
               completion:(SendMessageCompletion)completion {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    NSString *userIDs = [usersIDs componentsJoinedByString:@","];
    
    QBChatMessage *chatMessage = [[QBChatMessage alloc] init];
    chatMessage.senderID = currentUserID;
    chatMessage.text = text;
    chatMessage.customParameters[@"save_to_history"] = @"1";
    if (action == DialogActionTypeAdd) {
        chatMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeAdding)];
        chatMessage.customParameters[@"new_occupants_ids"] = [NSString stringWithFormat:@"%@", userIDs];
    } else if (action == DialogActionTypeCreate) {
        chatMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
    }
    chatMessage.deliveredIDs = @[@(currentUserID)];
    chatMessage.readIDs = @[@(currentUserID)];
    chatMessage.dateSent = NSDate.now;
    
    QBChatMessage *systemMessage = [[QBChatMessage alloc] init];
    systemMessage.senderID = currentUserID;
    systemMessage.text = text;
    systemMessage.deliveredIDs = @[@(currentUserID)];
    systemMessage.readIDs = @[@(currentUserID)];
    systemMessage.dateSent = NSDate.now;
    
    systemMessage.customParameters[@"dialog_id"] = dialog.ID;
    if (action == DialogActionTypeAdd) {
        systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeAdding)];
    } else if (action == DialogActionTypeCreate) {
        systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
    }
    
    // send system messages
    [dialog sendMessage:chatMessage completionBlock:^(NSError * _Nullable error) {
        if (completion) {
            if (error) {
                completion(error, chatMessage);
                if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                    [self.delegate chatManager:self didFailUpdateStorage:@"Chat is not connected"];
                }
                return;
            } else
                completion(nil, chatMessage);
            for (NSNumber *occupantID in usersIDs) {
                if (currentUserID == occupantID.integerValue) {
                    continue;
                }
                systemMessage.recipientID = occupantID.unsignedIntegerValue;
                [QBChat.instance sendSystemMessage:systemMessage completion:^(NSError * _Nullable error) {
                }];
            }
        }
    }];
}

// MARK: - Dialogs
- (void)createGroupDialogWithName:(NSString *)name
                        occupants:(NSArray<QBUUser *> *)occupants
                       completion:(nullable DialogCompletion)completion {
    NSMutableSet *occupantIDs = [NSMutableSet set];
    for (QBUUser *user in occupants) {
        NSAssert([user isKindOfClass:[QBUUser class]], @"occupants must be an array of QBUUser instances");
        [occupantIDs addObject:@(user.ID)];
    }
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = name;
    chatDialog.occupantIDs = occupantIDs.allObjects;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull dialog) {
        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
            //Notify about create new dialog
            NSString *infoMessage = [NSString stringWithFormat:@"%@%@", @"created the group chat ", dialog.name];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:infoMessage];
            }
            completion(error, dialog);
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response.error.error, nil);
        }
    }];
}

- (void) leaveDialogWithID:(NSString *)dialogId completion:(nullable MessagesErrorHandler)completion {
    QBChatDialog *dialog = [self.storage  dialogWithID:dialogId];
    if (!dialog) {
        if (completion) {
            completion(@"Dialog doesn't exist");
        }
        return;
    }
    
   if (dialog.type == QBChatDialogTypeGroup) {
        [QBRequest updateDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull tDialog) {
            [self.storage deleteDialogWithID:tDialog.ID];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
            }
            if (completion) {
                completion(nil);
            }
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
                [self.storage deleteDialogWithID:dialogId];
            }
            NSString *errorMessage = [self errorMessageWithResponse:response];
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:errorMessage];
            }
            if (completion) {
                completion(errorMessage);
            }
        }];
    }
}

- (void)loadDialogWithID:(NSString *)dialogId completion:(void(^)(QBChatDialog *loadedDialog))completion {
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:1 skip:0];
    NSDictionary *extendedRequest = @{@"_id": dialogId};
    
    [QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse * _Nonnull response, NSArray<QBChatDialog *> * _Nonnull dialogs, NSSet<NSNumber *> * _Nonnull dialogsUsersIDs, QBResponsePage * _Nonnull page) {
        if (dialogs.count == 0) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        NSSet *existingUsersIDs = [self.storage fetchAllUsersIDs];
        NSMutableSet *dialogUsersIDs = dialogsUsersIDs.mutableCopy;
        if (existingUsersIDs.count) {
            [dialogUsersIDs minusSet:existingUsersIDs];
        }
        if (dialogUsersIDs.count) {
            NSArray *usersIDs = [dialogUsersIDs allObjects];
            [self loadUsersWithUsersIDs:usersIDs completion:^(QBResponse *response) {}];
        }
        
        QBChatDialog *chatDialog = dialogs.firstObject;
        
        [self.storage updateDialogs:@[chatDialog] completion:^(NSError * _Nullable error) {
            if (completion) {
                completion(chatDialog);
            }
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(nil);
        }
        Log(@"%@ loadDialog error: %@",NSStringFromClass([ChatManager class]),
            [self errorMessageWithResponse:response]);
    }];
}

- (void)loadUserWithID:(NSUInteger)ID completion:(void(^)(QBUUser * _Nullable user))completion {
    [QBRequest userWithID:ID successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        [self.storage updateUsers:@[user]];
        if (completion) {
            completion(user);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"%@ loadUser error: %@",NSStringFromClass([ChatManager class]),
            [self errorMessageWithResponse:response]);
        if (completion) {
            completion(nil);
        } 
    }];
}

- (void)prepareDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    
    QBChatDialog *dialog = [self.storage dialogWithID:dialogId];
    if (dialog) {
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.dateSent;
        dialog.updatedAt = message.dateSent;
        if (message.senderID != currentUserID) {
            dialog.unreadMessagesCount = dialog.unreadMessagesCount + 1;
        }
        Log(@"dialog.unreadMessagesCount: %@", @(dialog.unreadMessagesCount));
        if (message.attachments.count) {
            dialog.lastMessageText = @"[Attachment]";
        }
        if (message.customParameters[@"notification_type"]) {
            NSString *typeLeave = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeLeave)];
            NSString *typeAdd = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeAdding)];
            if ([message.customParameters[@"notification_type"] isEqualToString: typeAdd]) {
                NSArray *occupantIDs = dialog.occupantIDs;
                NSString *strIDs = message.customParameters[@"new_occupants_ids"];
                NSArray *strArrayIDs = [strIDs componentsSeparatedByString:@","];
                NSMutableArray *newOccupantIDs = [NSMutableArray array];
                NSMutableArray *missingOccupantIDs = [NSMutableArray array];
                for (NSString *strID in strArrayIDs) {
                    if ([occupantIDs containsObject: @(strID.integerValue)]) {
                        continue;
                    }
                    [newOccupantIDs addObject:@(strID.integerValue)];
                    if (![self.storage userWithID:strID.integerValue]) {
                        [missingOccupantIDs addObject:@(strID.integerValue)];
                    }
                }
                if (missingOccupantIDs.count) {
                    NSMutableArray *newUsers = [NSMutableArray array];
                    for (NSNumber *ID in missingOccupantIDs) {
                        [newUsers addObject:ID.stringValue];
                    }
                    [QBRequest usersWithIDs:newUsers
                                       page:nil
                               successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
                        [self.storage updateUsers:users];
                        
                        dialog.occupantIDs = [occupantIDs arrayByAddingObjectsFromArray:newOccupantIDs];
                        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                                [self.delegate chatManager:self didUpdateChatDialog:dialog];
                            }
                        }];
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        Log(@"%@ prepareDialog error: %@",NSStringFromClass([ChatManager class]),
                            [self errorMessageWithResponse:response]);
                    }];
                    
                } else {
                    dialog.occupantIDs = [occupantIDs arrayByAddingObjectsFromArray:newOccupantIDs];
                    [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                        if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                            [self.delegate chatManager:self didUpdateChatDialog:dialog];
                        }
                    }];
                }
            } else if ([message.customParameters[@"notification_type"] isEqualToString: typeLeave]) {
                
                if ([dialog.occupantIDs containsObject: @(message.senderID)]) {
                    NSMutableArray *occupantIDs = [NSMutableArray arrayWithArray: dialog.occupantIDs];
                    
                    [occupantIDs removeObject:@(message.senderID)];
                    
                    dialog.occupantIDs = [occupantIDs copy];
                    [self.storage updateDialogs:@[dialog] completion:nil];
                }
            } else {
                [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                        [self.delegate chatManager:self didUpdateChatDialog:dialog];
                    }
                }];
            }
        } else {
            [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                    [self.delegate chatManager:self didUpdateChatDialog:dialog];
                }
            }];
        }
    } else {
        
        [self loadDialogWithID:dialogId completion:^(QBChatDialog * _Nonnull loadedDialog) {
            if (loadedDialog) {
                NSString *typeCreate = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
                if (message.customParameters[@"notification_type"] != nil &&
                    [message.customParameters[@"notification_type"] isEqualToString: typeCreate]) {
                    loadedDialog.unreadMessagesCount = 1;
                }
                loadedDialog.lastMessageText = message.text;
                if (message.attachments.count) {
                    loadedDialog.lastMessageText = @"[Attachment]";
                }
                loadedDialog.updatedAt = [NSDate date];
                [self.storage updateDialogs:@[loadedDialog] completion:^(NSError * _Nullable error) {
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                        [self.delegate chatManager:self didUpdateChatDialog:loadedDialog];
                    }
                }];
            } else {
                return;
            }
        }];
    }
}

- (void)updateDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message {
    QBUUser *userSender = [self.storage userWithID: message.senderID];
    if (!userSender) {
        [QBRequest userWithID:message.senderID successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
            [self.storage updateUsers:@[user]];
            [self prepareDialogWith:dialogId withMessage:message];
        } errorBlock:^(QBResponse * _Nonnull response) {
            Log(@"%@ updateDialog error: %@",NSStringFromClass([ChatManager class]),
                [self errorMessageWithResponse:response]);
        }];
    } else {
        [self prepareDialogWith:dialogId withMessage:message];
    }
}

//MARK: - Messages
- (void)messagesWithDialogID:(NSString *)dialogId
             extendedRequest:(nullable NSDictionary *)extendedParameters
                        skip:(NSInteger)skip
                     success:(nullable MessagesCompletion)success
                errorHandler:(nullable MessagesErrorHandler)errorHandler {
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:kMessagesLimitPerDialog skip:skip];
    NSDictionary *extendedRequest = extendedParameters.count > 0 ? extendedParameters : [self parametersForMessages];
    [QBRequest messagesWithDialogID:dialogId
                    extendedRequest:extendedRequest
                            forPage:responsePage
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page)
     {
        NSArray *sortedMessages = [[messages reverseObjectEnumerator] allObjects];
        Boolean cancel = NO;
        NSInteger numberOfMessages = sortedMessages.count;
        cancel = numberOfMessages < page.limit ? YES : NO;
        if (success) {
            success(sortedMessages, cancel);
        }
    } errorBlock:^(QBResponse *response) {
        if (errorHandler) {
            errorHandler([self errorMessageWithResponse:response]);
        }
    }];
}

- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion {
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(error);
            }
        } else {
            dialog.updatedAt = [NSDate date];
            [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                    [self.delegate chatManager:self didUpdateChatDialog:dialog];
                }
                if (completion) {
                    completion(nil);
                }
            }];
        }
    }];
}

- (void)readMessage:(QBChatMessage *)message
             dialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    if   (![message.dialogID isEqualToString: dialog.ID])  {
        return;
    }
    if (![message.deliveredIDs containsObject:@(currentUserID)]) {
        [QBChat.instance markAsDelivered:message completion:^(NSError * _Nullable error) {
            
        }];
    }
    [QBChat.instance readMessage:message completion:^(NSError * _Nullable error) {
        
        if (error != nil) {
            if (completion) {
                completion(error);
            }
            return;
        }
        
        // updating dialog
        if (dialog.unreadMessagesCount > 0) {
            dialog.unreadMessagesCount = dialog.unreadMessagesCount - 1;
        }
        
        if (UIApplication.sharedApplication.applicationIconBadgeNumber > 0) {
            UIApplication.sharedApplication.applicationIconBadgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber - 1;
        }
        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
            if (completion) {
                completion(nil);
            }
        }];
    }];
}

- (void)readMessages:(NSArray<QBChatMessage*> *)messages
              dialog:(QBChatDialog *)dialog
          completion:(QBChatCompletionBlock)completion {
    if (!QBSession.currentSession.currentUserID) {
        return;
    }
    NSInteger currentUserID = QBSession.currentSession.currentUserID;
    dispatch_group_t readGroup = dispatch_group_create();
    
    for (QBChatMessage *message in messages) {
        if   (![message.dialogID isEqualToString: dialog.ID])  {
            continue;
        }
        dispatch_group_enter(readGroup);
        
        if (![message.deliveredIDs containsObject:@(currentUserID)]) {
            [QBChat.instance markAsDelivered:message completion:^(NSError * _Nullable error) {
                
            }];
        }
        
        [QBChat.instance readMessage:message completion:^(NSError * _Nullable error) {
            
            if (error == nil) {
                // updating dialog
                if (dialog.unreadMessagesCount > 0) {
                    dialog.unreadMessagesCount = dialog.unreadMessagesCount - 1;
                }
                
                if (UIApplication.sharedApplication.applicationIconBadgeNumber > 0) {
                    UIApplication.sharedApplication.applicationIconBadgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber - 1;
                }
                dispatch_group_leave(readGroup);
                
            } else {
                if (completion) {
                    completion(error);
                }
                dispatch_group_leave(readGroup);
                return;
            }
        }];
    }
    dispatch_group_notify(readGroup, dispatch_get_main_queue(), ^{
        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
            if (completion) {
                completion(nil);
            }
        }];
    });
}

- (void)joinOccupantsWithIDs:(NSArray<NSNumber*> *)ids
                    toDialog:(QBChatDialog *)dialog
                  completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    NSMutableArray * pushOccupantsIDs = [NSMutableArray array];
    for (NSNumber *ID in ids) {
        [pushOccupantsIDs addObject:ID.stringValue];
    }
    dialog.pushOccupantsIDs = [pushOccupantsIDs copy];
    
    [QBRequest updateDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
        dialog.pushOccupantsIDs = @[];
        [self.storage updateDialogs:@[updatedDialog] completion:^(NSError * _Nullable error) {
            if (completion) {
                completion(response, updatedDialog);
            }
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        dialog.pushOccupantsIDs = @[];
        if (completion) {
            completion(response, nil);
        }
    }];
}

//MARK: - Connect/Disconnect
- (void)connect:(nullable QBChatCompletionBlock)completion {
    if (!QBSession.currentSession.currentUserID) {
        if (completion) {
            completion([NSError errorWithDomain:kChatServiceDomain
                                           code:kErrorDomaimCode
                                       userInfo:@{NSLocalizedDescriptionKey: @"Please enter your login and username."}]);
            
        }
        return;
    }
    Profile *profile = [[Profile alloc] init];
    NSString *password = profile.password;
    NSUInteger ID = profile.ID;
    if (QBSession.currentSession.currentUser) {
        QBUUser *currentUser = QBSession.currentSession.currentUser;
        password = currentUser.password;
        ID = currentUser.ID;
    }
    
    if (QBChat.instance.isConnected) {
        if (completion) {
            completion(nil);
        }
    } else {
        QBSettings.autoReconnectEnabled = YES;
        [QBChat.instance connectWithUserID:ID password:password completion:completion];
    }
}

- (void)disconnect:(nullable QBChatCompletionBlock)completion {
    [QBChat.instance disconnectWithCompletionBlock:completion];
}

//MARK: - Internal Methods
//MARK: - Users
- (void)searchUsersName:(NSString *)name
            currentPage:(NSUInteger)currentPage
                perPage:(NSUInteger)perPage
             completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion {
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage];
    [QBRequest usersWithFullName:name page:page successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        BOOL cancel = users.count < page.perPage;
        if (completion) {
            completion(response, users, cancel);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response, @[], NO);
        }
    }];
}

- (void)fetchUsersWithCurrentPage:(NSUInteger)currentPage
                          perPage:(NSUInteger)perPage
                       completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion {
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage];
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date last_request_at"} page:page successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        BOOL cancel = users.count < page.perPage;
        if (completion) {
            completion(response, users, cancel);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response, @[], NO);
        }
    }];
}

- (void)updateUsersWithCompletion:(void(^)(QBResponse *response))completion {
    QBGeneralResponsePage *firstPage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date last_request_at"} page:firstPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        [self.storage updateUsers:users];
        if (completion) {
            completion(response);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response);
        }
    }];
}

- (void)loadUsersWithUsersIDs:(NSArray<NSString *> *)usersIDs
                   completion:(void(^)(QBResponse *response))completion {
    __block NSUInteger skip = 1;
    __block void(^t_request)(QBGeneralResponsePage *usersPage);
    void(^request)(QBGeneralResponsePage *usersPage) = ^(QBGeneralResponsePage *usersPage) {
        
        [QBRequest usersWithIDs:usersIDs page:usersPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
            
            [self.storage updateUsers:users];
            skip = skip + 1;
            BOOL cancel = users.count < kUsersLimit ? YES : NO;
            if (cancel == NO) {
                t_request([QBGeneralResponsePage responsePageWithCurrentPage:skip perPage:kUsersLimit]);
            } else {
                
                if (completion) {
                    completion(response);
                }
                t_request = nil;
            }
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (completion) {
                completion(response);
            }
            t_request = nil;
        }];
        
    };
    t_request = [request copy];
    request([QBGeneralResponsePage responsePageWithCurrentPage:skip perPage:kUsersLimit]);
}

//MARK: - Dialogs
- (void)updateAllDialogsWithPageLimit:(NSInteger)limit
                      extendedRequest:(nullable NSDictionary *)extendedParameters
                       iterationBlock:(nullable DialogsIterationHandler)iterationBlock
                           completion:(void(^)(QBResponse *response))completion {
    NSDictionary *extendedRequest = [self parametersForMessages];
    __block  NSMutableSet *usersForUpdate = [NSMutableSet set];
    __block void(^t_request)(QBResponsePage *responsePage);
    void(^request)(QBResponsePage *responsePage) = ^(QBResponsePage *responsePage) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsersIDs, QBResponsePage *page)
         {
            for (NSNumber *ID in dialogsUsersIDs) {
                [usersForUpdate addObject:ID.stringValue];
            }
            
            [self.storage updateDialogs:dialogs completion:nil];
            page.skip += dialogs.count;
            BOOL cancel = page.totalEntries <= page.skip;
            
            if (iterationBlock != nil) {
                iterationBlock(response, dialogs, dialogsUsersIDs, cancel);
            }
            if (cancel == NO) {
                t_request(page);
            } else {
                NSSet *existingUsersIDs = [self.storage fetchAllUsersIDs];
                [usersForUpdate minusSet:existingUsersIDs];
                if (!usersForUpdate.count) {
                    if (completion) {
                        completion(response);
                    }
                    t_request = nil;
                    return;
                }

                NSArray *usersIDs = [usersForUpdate allObjects];
                NSLog(@"usersForUpdate count = %@", @(usersIDs.count));
                [self loadUsersWithUsersIDs:usersIDs completion:^(QBResponse *response) {
                }];
                if (completion) {
                    completion(response);
                }
                t_request = nil;
            }
            
            
        } errorBlock:^(QBResponse *response) {
            if (completion) {
                completion(response);
            }
            t_request = nil;
        }];
    };
    t_request = [request copy];
    request([QBResponsePage responsePageWithLimit:limit]);
}

//MARK: - Messages
- (NSDictionary *)parametersForMessages {
    NSDictionary *parameters = @{@"sort_desc": @"date_sent", @"mark_as_read": @"0"};
    return parameters;
}

//Handle Error
- (NSString *)errorMessageWithResponse:(QBResponse *)response {
    
    switch (response.status) {
        case 502: return @"Bad Gateway, please try again";
        case -1009: return @"Connection network error, please try again";
        case -1020: return @"Connection network error, please try again";
        case -1002: return @"Connection network error, please try again";
        default: {
            NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"("
                                                                                             withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            return errorMessage;
        }
    }
}

@end
