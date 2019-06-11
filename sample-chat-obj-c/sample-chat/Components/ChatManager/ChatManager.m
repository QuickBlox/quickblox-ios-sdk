//
//  ChatManager.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatManager.h"
#import <Quickblox/Quickblox.h>
#import "ChatStorage.h"
#import "Profile.h"
#import "Constants.h"
#import "Log.h"

static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";
static NSUInteger const kMessagesLimitPerDialog = 30;
static NSUInteger const kErrorDomaimCode = -1000;

typedef void(^DialogsIterationHandler)(QBResponse *response, NSArray<QBChatDialog *> *objects , NSSet<NSNumber *> *usersIDs, Boolean stop);
typedef void(^DialogsPage)(QBResponsePage *page);
typedef void(^UsersPage)(QBGeneralResponsePage *page);


@interface ChatManager ()

@end

@implementation ChatManager

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
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

//MARK: - Public Methods
- (void)updateStorage {
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    dispatch_group_t loadGroup = dispatch_group_create();
    
    if (QBChat.instance.isConnected == NO) {
        if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
            [self.delegate chatManager:self didFailUpdateStorage:NSLocalizedString(@"SA_STR_NETWORK_ERROR", nil)];
        }
        return;
    }
    __block NSString *message;
    
    dispatch_group_enter(loadGroup);
    [self updateUsersWithCompletion:^(QBResponse *response) {
        if (response) {
            message = [self errorMessageWithResponse:response];
        }
        dispatch_group_leave(loadGroup);
    }];
    
    dispatch_group_enter(loadGroup);
    [self updateAllDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:nil completion:^(QBResponse *response) {
        if (response) {
            message = [self errorMessageWithResponse:response];
        }
        dispatch_group_leave(loadGroup);
    }];
    
    dispatch_group_notify(loadGroup, dispatch_get_main_queue(), ^{
        if (message) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:message];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
            }
        }
    });
}

//MARK: - System Messages
- (void)sendLeaveMessage:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.senderID = currentUser.ID;
    message.text = text;
    message.deliveredIDs = @[@(currentUser.ID)];
    message.readIDs = @[@(currentUser.ID)];
    message.customParameters[@"save_to_history"] = @"1";
    message.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeLeave)];
    
    QBChatMessage *systemMessage = [[QBChatMessage alloc] init];
    systemMessage.senderID = currentUser.ID;
    systemMessage.text = text;
    systemMessage.deliveredIDs = @[@(currentUser.ID)];
    systemMessage.readIDs = @[@(currentUser.ID)];
    systemMessage.customParameters[@"dialog_id"] = dialog.ID;
    systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeLeave)];
    
    
    // send system messages
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = dialog.occupantIDs.count;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
            if (completion) {
                completion(error);
            }
        }];
    }];
    
    NSBlockOperation *systemMessagesOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (NSNumber *occupantID in dialog.occupantIDs) {
            if (currentUser.ID == occupantID.integerValue) {
                continue;
            }
            systemMessage.recipientID = occupantID.unsignedIntegerValue;
            [QBChat.instance sendSystemMessage:systemMessage completion:^(NSError * _Nullable error) {
                if (completion) {
                    completion(error);
                }
            }];
        }
    }];
    
    [systemMessagesOperation addDependency:completionOperation];
    [operationQueue addOperations:@[systemMessagesOperation, completionOperation] waitUntilFinished:NO];
}

- (void)sendAddingMessage:(NSString *)text
                   action:(DialogActionType)action
                withUsers:(NSArray<NSNumber *> *)usersIDs
                 toDialog:(QBChatDialog *)dialog
               completion:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    NSString *userIDs = [usersIDs componentsJoinedByString:@","];
    
    QBChatMessage *chatMessage = [[QBChatMessage alloc] init];
    chatMessage.senderID = currentUser.ID;
    chatMessage.text = text;
    chatMessage.customParameters[@"save_to_history"] = @"1";
    if (action == DialogActionTypeAdd) {
        chatMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeAdding)];
        chatMessage.customParameters[@"new_occupants_ids"] = [NSString stringWithFormat:@"%@", userIDs];
    } else if (action == DialogActionTypeCreate) {
        chatMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
    }
    chatMessage.deliveredIDs = @[@(currentUser.ID)];
    chatMessage.readIDs = @[@(currentUser.ID)];
    
    QBChatMessage *systemMessage = [[QBChatMessage alloc] init];
    systemMessage.senderID = currentUser.ID;
    systemMessage.text = text;
    systemMessage.deliveredIDs = @[@(currentUser.ID)];
    systemMessage.readIDs = @[@(currentUser.ID)];
    systemMessage.customParameters[@"dialog_id"] = dialog.ID;
    if (action == DialogActionTypeAdd) {
        systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeAdding)];
    } else if (action == DialogActionTypeCreate) {
        systemMessage.customParameters[@"notification_type"] = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
    }
    
    // send system messages
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = usersIDs.count;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [dialog sendMessage:chatMessage completionBlock:^(NSError * _Nullable error) {
            if (completion) {
                completion(error);
            }
        }];
    }];
    
    NSBlockOperation *systemMessagesOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (NSNumber *occupantID in usersIDs) {
            if (currentUser.ID == occupantID.integerValue) {
                continue;
            }
            systemMessage.recipientID = occupantID.unsignedIntegerValue;
            [QBChat.instance sendSystemMessage:systemMessage completion:^(NSError * _Nullable error) {
                if (completion) {
                    completion(error);
                }
            }];
        }
    }];
    
    [completionOperation addDependency:systemMessagesOperation];
    [operationQueue addOperations:@[systemMessagesOperation, completionOperation] waitUntilFinished:NO];
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
        [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(response, nil);
                }
                return;
            }
            [self.storage updateDialogs:@[dialog]];
            //Notify about create new dialog
            NSString *dialogName = dialog.name;
            NSString *infoMessage = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SA_STR_CREATE_NEW", nil), dialogName];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:infoMessage];
            }
            if (completion) {
                completion(response, dialog);
            }
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response, nil);
        }
    }];
}

- (void)createPrivateDialogWithOpponent:(QBUUser *)opponent
                             completion:(nullable DialogCompletion)completion {
    NSAssert(opponent.ID > 0, @"Incorrect user ID");
    
    QBChatDialog *localDialog = [self.storage privateDialogWithOpponentID:opponent.ID];
    if (localDialog && completion) {
        completion(nil, localDialog);
    } else {
        Profile *currentUser = [[Profile alloc] init];
        if (currentUser.isFull == NO) {
            return;
        }
        QBChatDialog *dialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
        dialog.occupantIDs = @[@(opponent.ID), @(currentUser.ID)];
        [QBRequest createDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull createdDialog) {
            [self.storage updateDialogs:@[createdDialog]];
            //Notify about create new dialog
            NSString *dialogName = createdDialog.name;
            NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SA_STR_CREATE_NEW", nil), dialogName];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:message];
            }
            if (completion) {
                completion(response, createdDialog);
            }
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (completion) {
                completion(response, nil);
            }
        }];
    }
}

- (void)deleteDialogWithID:(NSString *)dialogId completion:(nullable void(^)(QBResponse *response))completion {
    QBChatDialog *dialog = [self.storage  dialogWithID:dialogId];
    NSSet *dialogsWithIDs = [NSSet setWithArray:@[dialogId]];
    
    if (dialog) {
        [QBRequest deleteDialogsWithIDs:dialogsWithIDs forAllUsers:NO successBlock:^(QBResponse * _Nonnull response, NSArray<NSString *> * _Nonnull deletedObjectsIDs, NSArray<NSString *> * _Nonnull notFoundObjectsIDs, NSArray<NSString *> * _Nonnull wrongPermissionsObjectsIDs) {
            [self.storage deleteDialogWithID:dialogId];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
            }
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
                [self.storage deleteDialogWithID:dialogId];
            }
            NSString *errorMessage = [self errorMessageWithResponse:response];
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:errorMessage];
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
        QBChatDialog *chatDialog = dialogs.firstObject;
        
        [self.storage updateDialogs:@[chatDialog]];
        if (completion) {
            completion(chatDialog);
        }
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
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    
    QBChatDialog *dialog = [self.storage dialogWithID:dialogId];
    if (dialog) {
        
        
        dialog.lastMessageText = message.text;
        dialog.updatedAt = message.dateSent;
        if (message.senderID != currentUser.ID) {
            dialog.unreadMessagesCount += 1;
        }
        
        if (message.attachments.count) {
            dialog.lastMessageText = @"[Attachment]";
        }
        
        if (message.customParameters[@"notification_type"] != nil) {
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
                                   [self.storage updateDialogs:@[dialog]];
                                   if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                                       [self.delegate chatManager:self didUpdateChatDialog:dialog];
                                   }
                               } errorBlock:^(QBResponse * _Nonnull response) {
                                   Log(@"%@ prepareDialog error: %@",NSStringFromClass([ChatManager class]),
                                       [self errorMessageWithResponse:response]);
                               }];
                    
                } else {
                    
                    dialog.occupantIDs = [occupantIDs arrayByAddingObjectsFromArray:newOccupantIDs];
                    [self.storage updateDialogs:@[dialog]];
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                        [self.delegate chatManager:self didUpdateChatDialog:dialog];
                    }
                }
                
            } else if ([message.customParameters[@"notification_type"] isEqualToString: typeLeave]) {
                
                if ([dialog.occupantIDs containsObject: @(message.senderID)]) {
                    NSMutableArray *occupantIDs = [NSMutableArray arrayWithArray: dialog.occupantIDs];
                    
                    [occupantIDs removeObject:@(message.senderID)];
                    
                    dialog.occupantIDs = [occupantIDs copy];
                    [self.storage updateDialogs:@[dialog]];
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                        [self.delegate chatManager:self didUpdateChatDialog:dialog];
                    }
                }
            }
        } else {
            [self.storage updateDialogs:@[dialog]];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
        }
        
    } else {
        
        [self loadDialogWithID:dialogId completion:^(QBChatDialog * _Nonnull loadedDialog) {
            if (loadedDialog == nil) {
                return;
            }
            loadedDialog.lastMessageText = message.text;
            if (message.attachments.count) {
                dialog.lastMessageText = @"[Attachment]";
            }
            loadedDialog.updatedAt = [NSDate date];
            NSString *typeCreate = [NSString stringWithFormat:@"%@", @(NotificationMessageTypeCreate)];
            if (message.customParameters[@"notification_type"] != nil &&
                [message.customParameters[@"notification_type"] isEqualToString: typeCreate]) {
                loadedDialog.unreadMessagesCount = 1;
            }
        
            [self.storage updateDialogs:@[loadedDialog]];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:loadedDialog];
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
            [self.storage updateDialogs:@[dialog]];
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)readMessage:(QBChatMessage *)message
             dialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    if   (![message.dialogID isEqualToString: dialog.ID])  {
        return;
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
        [self.storage updateDialogs:@[dialog]];
        if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
            [self.delegate chatManager:self didUpdateChatDialog:dialog];
        }
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)readMessages:(NSArray<QBChatMessage*> *)messages
              dialog:(QBChatDialog *)dialog
          completion:(QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    
    dispatch_group_t readGroup = dispatch_group_create();
    
    for (QBChatMessage *message in messages) {
        if   (![message.dialogID isEqualToString: dialog.ID])  {
            continue;
        }
        dispatch_group_enter(readGroup);
        
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
        [self.storage updateDialogs:@[dialog]];
        if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
            [self.delegate chatManager:self didUpdateChatDialog:dialog];
        }
        if (completion) {
            completion(nil);
        }
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
        [self.storage updateDialogs:@[updatedDialog]];
        if (completion) {
            completion(response, updatedDialog);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        dialog.pushOccupantsIDs = @[];
        if (completion) {
            completion(response, nil);
        }
    }];
}

//MARK: - Connect/Disconnect
- (void)connect:(nullable QBChatCompletionBlock)completion {
    Profile *currentUser = [[Profile alloc] init];
    
    if ([currentUser isFull] == NO) {
        if (completion) {
            completion([NSError errorWithDomain:kChatServiceDomain
                                           code:kErrorDomaimCode
                                       userInfo:@{NSLocalizedDescriptionKey: @"Please enter your login and username."}]);
            
        }
        return;
    }
    
    if (QBChat.instance.isConnected) {
        if (completion) {
            completion(nil);
        }
    } else {
        QBSettings.autoReconnectEnabled = YES;
        [QBChat.instance connectWithUserID:[currentUser ID] password:[currentUser password] completion:completion];
    }
}

- (void)disconnect:(nullable QBChatCompletionBlock)completion {
    [QBChat.instance disconnectWithCompletionBlock:completion];
}

//MARK: - Internal Methods
//MARK: - Users
- (void)updateUsersWithCompletion:(void(^)(QBResponse *response))completion {
    QBGeneralResponsePage *firstPage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc string updated_at"} page:firstPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
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

//MARK: - Dialogs
- (void)updateAllDialogsWithPageLimit:(NSInteger)limit
                      extendedRequest:(nullable NSDictionary *)extendedParameters
                       iterationBlock:(nullable DialogsIterationHandler)iterationBlock
                           completion:(void(^)(QBResponse *response))completion {
    NSDictionary *extendedRequest = [self parametersForMessages];
    __block void(^t_request)(QBResponsePage *responsePage);
    void(^request)(QBResponsePage *responsePage) = ^(QBResponsePage *responsePage) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsersIDs, QBResponsePage *page)
         {
             
             [self.storage updateDialogs:dialogs];
             
             page.skip += dialogs.count;
             BOOL cancel = page.totalEntries <= page.skip;
             
             if (iterationBlock != nil) {
                 iterationBlock(response, dialogs, dialogsUsersIDs, cancel);
             }
             if (cancel == NO) {
                 t_request(page);
             } else {
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
        case 502: return NSLocalizedString(@"SA_STR_BAD_GATEWAY", nil);
        case 0: NSLocalizedString(@"SA_STR_NETWORK_ERROR", nil);
        default: {
            NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"("
                                                                                             withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            return errorMessage;
        }
    }
}

@end;
