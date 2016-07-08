//
//  QMChatService.m
//  QMServices
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QBChatMessage+QMCustomParameters.h"

#import "QMSLog.h"

const char *kChatCacheQueue = "com.q-municate.chatCacheQueue";
static NSString* const kQMChatServiceDomain = @"com.q-municate.chatservice";

#define kChatServiceSaveToHistoryTrue @"1"
#define kQMLoadedAllMessages          @1

@interface QMChatService() <QBChatDelegate>

@property (assign, nonatomic, readwrite) QMChatConnectionState chatConnectionState;
@property (strong, nonatomic) QBMulticastDelegate <QMChatServiceDelegate, QMChatConnectionDelegate> *multicastDelegate;
@property (weak, nonatomic) id <QMChatServiceCacheDataSource> cacheDataSource;
@property (strong, nonatomic) QMDialogsMemoryStorage *dialogsMemoryStorage;
@property (strong, nonatomic) QMMessagesMemoryStorage *messagesMemoryStorage;
@property (strong, nonatomic) QMChatAttachmentService *chatAttachmentService;

@property (weak, nonatomic)   BFTask* loadEarlierMessagesTask;
@property (strong, nonatomic) NSMutableDictionary *loadedAllMessages;
@property (strong, nonatomic) NSMutableDictionary *lastMessagesLoadDate;
@property (strong, nonatomic) NSMutableSet *messagesToRead;

@end

@implementation QMChatService

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    [QBChat.instance removeDelegate:self];
}

#pragma mark - Configure

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager cacheDataSource:(id<QMChatServiceCacheDataSource>)cacheDataSource {
    
    self = [super initWithServiceManager:serviceManager];
    
    if (self) {
        
        _cacheDataSource = cacheDataSource;
        
        _loadedAllMessages = [NSMutableDictionary dictionary];
        _lastMessagesLoadDate = [NSMutableDictionary dictionary];
        _messagesToRead = [NSMutableSet set];
        
        if (self.serviceManager.currentUser != nil) [self loadCachedDialogsWithCompletion:nil];
    }
    
    return self;
}

- (void)serviceWillStart {
    
    self.multicastDelegate = (id<QMChatServiceDelegate, QMChatConnectionDelegate>)[[QBMulticastDelegate alloc] init];
    self.dialogsMemoryStorage = [[QMDialogsMemoryStorage alloc] init];
    self.messagesMemoryStorage = [[QMMessagesMemoryStorage alloc] init];
    self.chatAttachmentService = [[QMChatAttachmentService alloc] init];
    
    [QBChat.instance addDelegate:self];
}

#pragma mark - Load cached data

- (void)loadCachedDialogsWithCompletion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    if ([self.cacheDataSource respondsToSelector:@selector(cachedDialogs:)]) {
        
        NSAssert(self.serviceManager.currentUser != nil, @"Current user must be non nil!");
        
        [weakSelf.cacheDataSource cachedDialogs:^(NSArray *collection) {
            
            if (collection.count > 0) {
                // We need only current users dialog
                
                NSArray *userDialogs = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%lu IN self.occupantIDs", self.serviceManager.currentUser.ID]];
                
                [weakSelf.dialogsMemoryStorage addChatDialogs:userDialogs andJoin:NO];
                
                if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogsToMemoryStorage:)]) {
                    [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogsToMemoryStorage:collection];
                }
                
                NSMutableSet *dialogsUsersIDs = [NSMutableSet set];
                for (QBChatDialog *dialog in userDialogs) {
                    [dialogsUsersIDs addObjectsFromArray:dialog.occupantIDs];
                }
                if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didLoadChatDialogsFromCache:withUsers:)]) {
                    [weakSelf.multicastDelegate chatService:weakSelf didLoadChatDialogsFromCache:userDialogs withUsers:dialogsUsersIDs.copy];
                }
            }
            
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)loadCachedMessagesWithDialogID:(NSString *)dialogID compleion:(void(^)())completion {
    
    if ([self.cacheDataSource respondsToSelector:@selector(cachedMessagesWithDialogID:block:)]) {
        
        __weak __typeof(self)weakSelf = self;
        [self.cacheDataSource cachedMessagesWithDialogID:dialogID block:^(NSArray *collection) {
            
            if (collection.count > 0) {
                
                if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didLoadMessagesFromCache:forDialogID:)]) {
                    [weakSelf.multicastDelegate chatService:weakSelf didLoadMessagesFromCache:collection forDialogID:dialogID];
                }
                
                [weakSelf.messagesMemoryStorage addMessages:collection forDialogID:dialogID];
                
                if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                    [weakSelf.multicastDelegate chatService:weakSelf didAddMessagesToMemoryStorage:collection forDialogID:dialogID];
                }
            }
            
            if (completion) {
                completion();
            }
        }];
    }
}

#pragma mark - Add / Remove Multicast delegate

- (void)addDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate{
    
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - QBChatDelegate

- (void)chatDidFailWithStreamError:(NSError *)error {
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidFailWithStreamError:)]) {
        
        [self.multicastDelegate chatServiceChatDidFailWithStreamError:error];
    }
}

- (void)chatDidConnect {
    
    self.chatConnectionState = QMChatConnectionStateConnected;
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidConnect:)]) {
        
        [self.multicastDelegate chatServiceChatDidConnect:self];
    }
}

- (void)chatDidNotConnectWithError:(NSError *)error {
    
    self.chatConnectionState = QMChatConnectionStateDisconnected;
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatService:chatDidNotConnectWithError:)]) {
        
        [self.multicastDelegate chatService:self chatDidNotConnectWithError:error];
    }
}

- (void)chatDidAccidentallyDisconnect {
    
    self.chatConnectionState = QMChatConnectionStateDisconnected;
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidAccidentallyDisconnect:)]) {
        
        [self.multicastDelegate chatServiceChatDidAccidentallyDisconnect:self];
    }
}

- (void)chatDidReconnect {
    
    self.chatConnectionState = QMChatConnectionStateConnected;
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidReconnect:)]) {
        
        [self.multicastDelegate chatServiceChatDidReconnect:self];
    }
}

#pragma mark Handle messages (QBChatDelegate)

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID
{
    [self handleChatMessage:message];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    [self handleChatMessage:message];
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message
{
    [self handleSystemMessage:message];
}

- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID
{
    NSParameterAssert(dialogID != nil);
    NSParameterAssert(messageID != nil);
    
    QBChatMessage* message = [self.messagesMemoryStorage messageWithID:messageID fromDialogID:dialogID];
    
    if (message != nil) {
        if (message.readIDs == nil) {
            message.readIDs = [NSArray array];
        }
        
        if (![message.readIDs containsObject:@(readerID)]) {
            message.readIDs = [message.readIDs arrayByAddingObject:@(readerID)];
            
            [self.messagesMemoryStorage updateMessage:message];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                [self.multicastDelegate chatService:self didUpdateMessage:message forDialogID:dialogID];
            }
            
            if (self.serviceManager.currentUser.ID == readerID) {
                
                QBChatDialog * dialog = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
                
                if (dialog.unreadMessagesCount > 0) {
                    //--
                    dialog.unreadMessagesCount--;
                    
                    if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                        [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:dialog];
                    }
                }
            }
        }
    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID
{
    NSParameterAssert(dialogID != nil);
    NSParameterAssert(messageID != nil);
    
    QBChatMessage* message = [self.messagesMemoryStorage messageWithID:messageID fromDialogID:dialogID];
    
    if (message != nil) {
        if (message.deliveredIDs == nil) {
            message.deliveredIDs = [NSArray array];
        }
        
        if (![message.deliveredIDs containsObject:@(userID)]) {
            message.deliveredIDs = [message.deliveredIDs arrayByAddingObject:@(userID)];
            
            [self.messagesMemoryStorage updateMessage:message];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                [self.multicastDelegate chatService:self didUpdateMessage:message forDialogID:dialogID];
            }
        }
    }
}

#pragma mark - Chat Login/Logout

- (void)connectWithCompletionBlock:(QBChatCompletionBlock)completion {
    
    if (!self.serviceManager.isAuthorized) {
        if (completion) completion([NSError errorWithDomain:kQMChatServiceDomain
                                                       code:-1000
                                                   userInfo:@{NSLocalizedRecoverySuggestionErrorKey : @"You are not authorized in REST."}]);
        return;
    }
    
    if ([QBChat instance].isConnected) {
        if(completion){
            completion(nil);
        }
    }
    else {
        [QBSettings setAutoReconnectEnabled:YES];
        
        if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatHasStartedConnecting:)]) {
            
            [self.multicastDelegate chatServiceChatHasStartedConnecting:self];
        }
        
        QBUUser *user = self.serviceManager.currentUser;
        
        self.chatConnectionState = QMChatConnectionStateConnecting;
        [[QBChat instance] connectWithUser:user completion:completion];
    }
}

- (void)disconnectWithCompletionBlock:(QBChatCompletionBlock)completion {
    
    [[QBChat instance] disconnectWithCompletionBlock:completion];
}

#pragma mark - Handle Chat messages

- (void)handleSystemMessage:(QBChatMessage *)message {
    
    if (message.messageType == QMMessageTypeCreateGroupDialog) {
        
        if ([self.dialogsMemoryStorage chatDialogWithID:message.dialogID] != nil) {
            
            return;
        }
        
        QBChatDialog *dialogToAdd = message.dialog;
        
        [self updateLastMessageParamsForChatDialog:dialogToAdd withMessage:message];
        dialogToAdd.updatedAt = message.dateSent;
        
        __weak __typeof(self)weakSelf = self;
        [self.dialogsMemoryStorage addChatDialog:dialogToAdd andJoin:self.isAutoJoinEnabled completion:^(QBChatDialog *addedDialog, NSError *error) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            
            if (message.senderID != self.serviceManager.currentUser.ID) {
                
                addedDialog.unreadMessagesCount++;
            }
            
            if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                
                [strongSelf.multicastDelegate chatService:strongSelf didAddChatDialogToMemoryStorage:addedDialog];
            }
        }];
    }
}

- (void)handleChatMessage:(QBChatMessage *)message {
    
    if (!message.dialogID) {
        
        QMSLog(@"Need update this case");
        
        return;
    }
    
    QBChatDialog *chatDialogToUpdate = [self.dialogsMemoryStorage chatDialogWithID:message.dialogID];
    
    if (message.messageType == QMMessageTypeText) {
        
        BOOL shouldSaveDialog = NO;
        
        //Update chat dialog in memory storage
        if (chatDialogToUpdate == nil) {
            
            chatDialogToUpdate = [[QBChatDialog alloc] initWithDialogID:message.dialogID type:QBChatDialogTypePrivate];
            
            BOOL isCarbon = [self.serviceManager currentUser].ID == message.recipientID;
            
            
            chatDialogToUpdate.occupantIDs = @[@([self.serviceManager currentUser].ID), @(isCarbon ? message.senderID: message.recipientID)];
            
            shouldSaveDialog = YES;
        }
        
        if (message.senderID != self.serviceManager.currentUser.ID
            && !(chatDialogToUpdate.type == QBChatDialogTypePrivate && message.delayed)) {
            
            chatDialogToUpdate.unreadMessagesCount++;
        }
        
        // updating dialog last message params
        [self updateLastMessageParamsForChatDialog:chatDialogToUpdate withMessage:message];
        chatDialogToUpdate.updatedAt = message.dateSent;
        
        if (shouldSaveDialog) {
            
            [self.dialogsMemoryStorage addChatDialog:chatDialogToUpdate andJoin:NO completion:nil];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                
                [self.multicastDelegate chatService:self didAddChatDialogToMemoryStorage:chatDialogToUpdate];
            }
        }
        else {
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
            }
        }
    }
    else if (message.messageType == QMMessageTypeUpdateGroupDialog
             && chatDialogToUpdate) {
        
        NSUInteger currentUserID = [self.serviceManager currentUser].ID;
        
        // if current user leaves the chat there is no need to update this dialog
        // therefore performing its deletion
        if ([message.deletedOccupantsIDs containsObject:@(currentUserID)]) {
            
            [self.dialogsMemoryStorage deleteChatDialogWithID:chatDialogToUpdate.ID];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
                
                [self.multicastDelegate chatService:self didDeleteChatDialogWithIDFromMemoryStorage:chatDialogToUpdate.ID];
            }
            
            return;
        }
        
        // new custom parameters handling
        if (message.dialogUpdateType != QMDialogUpdateTypeNone) {
            
            NSDate *updatedAt = nil;
            if (message.deletedOccupantsIDs.count > 0) {
                // using date sent of message due to dialogUpdatedAt being not server synchronized when user is leaving
                updatedAt = message.dateSent;
            }
            else {
                
                updatedAt = message.dialogUpdatedAt;
            }

            if ([chatDialogToUpdate.updatedAt compare:updatedAt] != NSOrderedDescending) {
                
                switch (message.dialogUpdateType) {
                        
                    case QMDialogUpdateTypeName:
                        chatDialogToUpdate.name = message.dialogName;
                        break;
                        
                    case QMDialogUpdateTypePhoto:
                        chatDialogToUpdate.photo = message.dialogPhoto;
                        break;
                        
                    case QMDialogUpdateTypeOccupants: {
                        
                        NSMutableSet *occupantsSet = [NSMutableSet setWithArray:chatDialogToUpdate.occupantIDs];
                        
                        if (message.addedOccupantsIDs.count > 0) {
                            
                            [occupantsSet addObjectsFromArray:message.addedOccupantsIDs];
                        }
                        else if (message.deletedOccupantsIDs.count > 0) {
                            
                            [occupantsSet minusSet:[NSSet setWithArray:message.deletedOccupantsIDs]];
                        }
                        
                        chatDialogToUpdate.occupantIDs = [occupantsSet allObjects];
                        
                        break;
                    }
                        
                    case QMDialogUpdateTypeNone:
                        break;
                }
                
                chatDialogToUpdate.updatedAt = updatedAt;
            }
            else {
                
                chatDialogToUpdate.updatedAt = message.dateSent;
            }
        }
        // old custom parameters handling
        else if (message.dialog != nil) {
            
            if (message.dialog.name != nil) {
                
                chatDialogToUpdate.name = message.dialog.name;
            }
            
            if (message.dialog.photo != nil) {
                
                chatDialogToUpdate.photo = message.dialog.photo;
            }
            
            if (message.dialog.occupantIDs.count > 0) {
                
                chatDialogToUpdate.occupantIDs = message.dialog.occupantIDs;
            }
            
            chatDialogToUpdate.updatedAt = message.dateSent;
        }
        
        if (message.senderID != currentUserID && ![message.addedOccupantsIDs containsObject:@(currentUserID)]) {
            
            chatDialogToUpdate.unreadMessagesCount++;
        }
        
        // updating dialog last message params
        [self updateLastMessageParamsForChatDialog:chatDialogToUpdate withMessage:message];
        
        if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
            
            [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
        }
    }
    else if (message.messageType == QMMessageTypeContactRequest
             || message.messageType == QMMessageTypeAcceptContactRequest
             || message.messageType == QMMessageTypeRejectContactRequest
             || message.messageType == QMMessageTypeDeleteContactRequest) {
        
        if (chatDialogToUpdate != nil) {
            
            chatDialogToUpdate.unreadMessagesCount++;
            
            // updating dialog last message params
            [self updateLastMessageParamsForChatDialog:chatDialogToUpdate withMessage:message];
            chatDialogToUpdate.updatedAt = message.dateSent;
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
            }
        }
        else {
            
            chatDialogToUpdate = [[QBChatDialog alloc] initWithDialogID:message.dialogID type:QBChatDialogTypePrivate];
            
            NSUInteger opponentID = message.senderID;
            
            if (message.senderID == self.serviceManager.currentUser.ID) {
                // message is carbon message
                opponentID = message.recipientID;
            }
            
            chatDialogToUpdate.occupantIDs = @[@(self.serviceManager.currentUser.ID), @(opponentID)];
            chatDialogToUpdate.unreadMessagesCount++;
            
            // updating dialog last message params
            [self updateLastMessageParamsForChatDialog:chatDialogToUpdate withMessage:message];
            chatDialogToUpdate.updatedAt = message.dateSent;
            
            [self.dialogsMemoryStorage addChatDialog:chatDialogToUpdate andJoin:NO completion:nil];
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                
                [self.multicastDelegate chatService:self didAddChatDialogToMemoryStorage:chatDialogToUpdate];
            }
        }
    }
    
    if ([message.saveToHistory isEqualToString:kChatServiceSaveToHistoryTrue]) {
        
        BOOL messageExists = [self.messagesMemoryStorage isMessageExistent:message forDialogID:message.dialogID];
        
        [self.messagesMemoryStorage addMessage:message forDialogID:message.dialogID];
        
        if (messageExists) {
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                
                [self.multicastDelegate chatService:self didUpdateMessage:message forDialogID:message.dialogID];
            }
        }
        else {
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
                
                [self.multicastDelegate chatService:self didAddMessageToMemoryStorage:message forDialogID:message.dialogID];
            }
        }
    }
    
    if (message.isNotificatonMessage && chatDialogToUpdate != nil) {
        
        if ([self.multicastDelegate respondsToSelector:@selector(chatService:didReceiveNotificationMessage:createDialog:)]) {
            
            [self.multicastDelegate chatService:self didReceiveNotificationMessage:message createDialog:chatDialogToUpdate];
        }
    }
}

#pragma mark - Group dialog join

- (void)joinToGroupDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion {
    
    NSParameterAssert(dialog.type != QBChatDialogTypePrivate);
    
    if (dialog.isJoined) {
        return;
    }
    
    NSString *dialogID = dialog.ID;
    
    [dialog joinWithCompletionBlock:^(NSError *error) {
        
        if (error != nil) {
            
            if (error.code == 201 || error.code == 404 || error.code == 407) {
                // dialog does not exist, removing it
                [self.dialogsMemoryStorage deleteChatDialogWithID:dialogID];
                
                if ([self.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
                    [self.multicastDelegate chatService:self didDeleteChatDialogWithIDFromMemoryStorage:dialogID];
                }
            }
            
            if (completion) completion(error);
        }
        else {
            if (completion) completion(nil);
        }
    }];
}


#pragma mark - Dialog history

- (void)allDialogsWithPageLimit:(NSUInteger)limit
                extendedRequest:(NSDictionary *)extendedRequest
                 iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iterationBlock
                     completion:(void(^)(QBResponse *response))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    __block QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:limit];
    __block BOOL cancel = NO;
    
    __block dispatch_block_t t_request;
    
    dispatch_block_t request = [^{
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if (![strongSelf.serviceManager isAuthorized]) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        
        [QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            
            NSArray *memoryStorageDialogs = [self.dialogsMemoryStorage unsortedDialogs];
            NSMutableArray *newDialogs = dialogObjects.mutableCopy;
            NSMutableArray *existentDialogs = dialogObjects.mutableCopy;
            
            [newDialogs removeObjectsInArray:memoryStorageDialogs];
            [existentDialogs removeObjectsInArray:newDialogs];
            
            [strongSelf.dialogsMemoryStorage addChatDialogs:dialogObjects andJoin:self.isAutoJoinEnabled];
            
            if (newDialogs.count > 0) {
                
                if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogsToMemoryStorage:)]) {
                    [strongSelf.multicastDelegate chatService:strongSelf didAddChatDialogsToMemoryStorage:newDialogs.copy];
                }
            }
            
            if (existentDialogs.count > 0) {
                
                if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogsInMemoryStorage:)]) {
                    [strongSelf.multicastDelegate chatService:strongSelf didUpdateChatDialogsInMemoryStorage:existentDialogs.copy];
                }
            }
            
            responsePage.skip += dialogObjects.count;
            
            if (page.totalEntries <= responsePage.skip) {
                cancel = YES;
            }
            
            iterationBlock(response, dialogObjects, dialogsUsersIDs, &cancel);
            
            if (!cancel) {
                t_request();
            } else {
                if (completion) {
                    completion(response);
                }
            }
            
        } errorBlock:^(QBResponse *response) {
            
            [strongSelf.serviceManager handleErrorResponse:response];
            
            if (completion) {
                completion(response);
            }
        }];
        
    } copy];
    
    t_request = request;
    request();
}

#pragma mark - Chat dialog creation

- (void)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID
                                   completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion {
    NSAssert(opponentID > 0, @"Incorrect user ID");
    
    QBChatDialog *dialog = [self.dialogsMemoryStorage privateChatDialogWithOpponentID:opponentID];
    
    if (!dialog) {
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = @[@(opponentID)];
        
        __weak __typeof(self)weakSelf = self;
        
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
            
            [weakSelf.dialogsMemoryStorage addChatDialog:createdDialog andJoin:NO completion:nil];
            
            //Notify about create new dialog
            
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogToMemoryStorage:createdDialog];
            }
            
            if (completion) {
                completion(response, createdDialog);
            }
            
            
        } errorBlock:^(QBResponse *response) {
            
            [weakSelf.serviceManager handleErrorResponse:response];
            
            if (completion) {
                completion(response, nil);
            }
        }];
    }
    else {
        
        if (completion) {
            completion(nil, dialog);
        }
    }
}

- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent
                                 completion:(void(^)(QBResponse *response, QBChatDialog *createdDialo))completion {
    
    [self createPrivateChatDialogWithOpponentID:opponent.ID completion:completion];
}

- (void)createGroupChatDialogWithName:(NSString *)name photo:(NSString *)photo occupants:(NSArray *)occupants
                           completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion {
    
    NSMutableSet *occupantIDs = [NSMutableSet set];
    
    for (QBUUser *user in occupants) {
        NSAssert([user isKindOfClass:[QBUUser class]], @"occupants must be an array of QBUUser instances");
        [occupantIDs addObject:@(user.ID)];
    }
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = name;
    chatDialog.photo = photo;
    chatDialog.occupantIDs = occupantIDs.allObjects;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        [weakSelf.dialogsMemoryStorage addChatDialog:createdDialog andJoin:self.isAutoJoinEnabled completion:^(QBChatDialog *addedDialog, NSError *error) {
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogToMemoryStorage:addedDialog];
            }
            
            if (completion) {
                completion(response, addedDialog);
            }
        }];
        
    } errorBlock:^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
}

#pragma mark - Edit dialog methods

- (void)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog
              completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    
    chatDialog.name = dialogName;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *updatedDialog) {
        
        [weakSelf.dialogsMemoryStorage addChatDialog:updatedDialog andJoin:self.isAutoJoinEnabled completion:^(QBChatDialog *addedDialog, NSError *error) {
            if (completion) {
                completion(response, addedDialog);
            }
        }];
        
    } errorBlock:^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
}

- (void)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    
    NSAssert(avatarPublicUrl != nil, @"avatarPublicUrl can't be nil");
    NSAssert(chatDialog != nil, @"Dialog can't be nil");
    
    chatDialog.photo = avatarPublicUrl;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *dialog) {
        //
        [weakSelf.dialogsMemoryStorage addChatDialog:dialog andJoin:self.isAutoJoinEnabled completion:^(QBChatDialog *addedDialog, NSError *error) {
            if (completion) completion(response, addedDialog);
        }];
    } errorBlock:^(QBResponse *response) {
        //
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) completion(response,nil);
    }];
}

- (void)joinOccupantsWithIDs:(NSArray *)ids toChatDialog:(QBChatDialog *)chatDialog
                  completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    chatDialog.pushOccupantsIDs = ids;
    
    [QBRequest updateDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *updatedDialog) {
        
        chatDialog.pushOccupantsIDs = @[];
        [weakSelf.dialogsMemoryStorage addChatDialog:updatedDialog andJoin:self.isAutoJoinEnabled completion:^(QBChatDialog *addedDialog, NSError *error) {
            if (completion) {
                completion(response, addedDialog);
            }
        }];
        
    } errorBlock:^(QBResponse *response) {
        
        chatDialog.pushOccupantsIDs = @[];
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
}

- (void)deleteDialogWithID:(NSString *)dialogId completion:(void (^)(QBResponse *))completion {
    
    NSParameterAssert(dialogId);
    
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:dialogId] forAllUsers:NO successBlock:^(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs) {
        //
        [weakSelf.dialogsMemoryStorage deleteChatDialogWithID:dialogId];
        [weakSelf.messagesMemoryStorage deleteMessagesWithDialogID:dialogId];
        
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
            [weakSelf.multicastDelegate chatService:weakSelf didDeleteChatDialogWithIDFromMemoryStorage:dialogId];
        }
        
        [weakSelf.loadedAllMessages removeObjectsForKeys:deletedObjectsIDs];
        
        if (completion) {
            completion(response);
        }
    } errorBlock:^(QBResponse *response) {
        //
        if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
            [weakSelf.dialogsMemoryStorage deleteChatDialogWithID:dialogId];
            
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didDeleteChatDialogWithIDFromMemoryStorage:dialogId];
            }
        }
        else {
            
            [weakSelf.serviceManager handleErrorResponse:response];
        }
        
        if (completion) {
            completion(response);
        }
    }];
}

#pragma mark - Messages histroy

- (void)deleteMessageLocally:(QBChatMessage *)message {
    NSAssert(message.dialogID, @"Message must have a dialog ID.");
    
    [self deleteMessagesLocally:@[message] forDialogID:message.dialogID];
}

- (void)deleteMessagesLocally:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSArray *messagesToDelete = messages.copy;
    [self.messagesMemoryStorage deleteMessages:messages forDialogID:dialogID];
    if ([self.multicastDelegate respondsToSelector:@selector(chatService:didDeleteMessagesFromMemoryStorage:forDialogID:)]) {
        [self.multicastDelegate chatService:self didDeleteMessagesFromMemoryStorage:messagesToDelete forDialogID:dialogID];
    }
}

- (void)messagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion {
    
    dispatch_group_t messagesLoadGroup = dispatch_group_create();
    if ([[self.messagesMemoryStorage messagesWithDialogID:chatDialogID] count] == 0) {
        
        // loading messages from cache
        dispatch_group_enter(messagesLoadGroup);
        [self loadCachedMessagesWithDialogID:chatDialogID compleion:^{
            
            dispatch_group_leave(messagesLoadGroup);
        }];
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_group_notify(messagesLoadGroup, dispatch_get_main_queue(), ^{
        __typeof(weakSelf)strongSelf = weakSelf;
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:strongSelf.chatMessagesPerPage];
        NSMutableDictionary *parameters = [@{@"sort_desc" : @"date_sent"} mutableCopy];
        
        NSDate *lastMessagesLoadDate = self.lastMessagesLoadDate[chatDialogID];
        QBChatMessage *lastMessage = [strongSelf.messagesMemoryStorage lastMessageFromDialogID:chatDialogID];
        
        if (lastMessagesLoadDate == nil && lastMessage != nil) {
            
            lastMessagesLoadDate = lastMessage.dateSent;
        }
        
        parameters[@"date_sent[gte]"] = @([lastMessagesLoadDate timeIntervalSince1970]);
        
        [QBRequest messagesWithDialogID:chatDialogID
                        extendedRequest:parameters
                                forPage:page
                           successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
                               
                               strongSelf.lastMessagesLoadDate[chatDialogID] = [NSDate date];
                               NSArray* sortedMessages = [[messages reverseObjectEnumerator] allObjects];
                               
                               if ([sortedMessages count] > 0) {
                                   
                                   if (lastMessage == nil) {
                                       
                                       [strongSelf.messagesMemoryStorage replaceMessages:sortedMessages forDialogID:chatDialogID];
                                       
                                       if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                                           
                                           [strongSelf.multicastDelegate chatService:strongSelf didAddMessagesToMemoryStorage:sortedMessages forDialogID:chatDialogID];
                                       }
                                   }
                                   else {
                                       
                                       NSArray *memoryStorageMessages = [strongSelf.messagesMemoryStorage messagesWithDialogID:chatDialogID];
                                       NSMutableArray *newMessages = sortedMessages.mutableCopy;
                                       NSMutableArray *existentMessages = sortedMessages.mutableCopy;
                                       
                                       [newMessages removeObjectsInArray:memoryStorageMessages];
                                       [existentMessages removeObjectsInArray:newMessages];
                                       
                                       [strongSelf.messagesMemoryStorage addMessages:sortedMessages forDialogID:chatDialogID];
                                       
                                       if (newMessages.count > 0) {
                                           
                                           if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                                               
                                               [strongSelf.multicastDelegate chatService:strongSelf didAddMessagesToMemoryStorage:newMessages forDialogID:chatDialogID];
                                           }
                                       }
                                       
                                       if (existentMessages.count > 0) {
                                           
                                           if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessages:forDialogID:)]) {
                                               
                                               [strongSelf.multicastDelegate chatService:strongSelf didUpdateMessages:existentMessages forDialogID:chatDialogID];
                                           }
                                       }
                                   }
                               }
                               
                               if (completion) {
                                   completion(response, sortedMessages);
                               }
                           } errorBlock:^(QBResponse *response) {
                               
                               // case where we may have deleted dialog from another device
                               if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
                                   [weakSelf.dialogsMemoryStorage deleteChatDialogWithID:chatDialogID];
                                   
                                   if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
                                       [weakSelf.multicastDelegate chatService:weakSelf didDeleteChatDialogWithIDFromMemoryStorage:chatDialogID];
                                   }
                               }
                               else {
                                   
                                   [weakSelf.serviceManager handleErrorResponse:response];
                               }
                               
                               if (completion) {
                                   completion(response, nil);
                               }
                           }];
    });
}

- (void)earlierMessagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion {
    
    if ([self.messagesMemoryStorage isEmptyForDialogID:chatDialogID]) {
        
        [self messagesWithChatDialogID:chatDialogID completion:completion];
        
        return;
    }
    
    QBChatMessage *oldestMessage = [self.messagesMemoryStorage oldestMessageForDialogID:chatDialogID];
    NSString *oldestMessageDate = [NSString stringWithFormat:@"%ld", (long)[oldestMessage.dateSent timeIntervalSince1970]];
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:self.chatMessagesPerPage];
    
    NSDictionary *extendedRequest = @{@"date_sent[lte]": oldestMessageDate,
                                      @"sort_desc" : @"date_sent",
                                      @"_id[lt]" : oldestMessage.ID};
    
    __weak __typeof(self) weakSelf = self;
    
    [QBRequest messagesWithDialogID:chatDialogID extendedRequest:extendedRequest forPage:page successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        
        if ([messages count] > 0) {
            
            [weakSelf.messagesMemoryStorage addMessages:messages forDialogID:chatDialogID];
            
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddMessagesToMemoryStorage:messages forDialogID:chatDialogID];
            }
        }
        
        if (completion) {
            completion(response, messages);
        }
        
    } errorBlock:^(QBResponse *response) {
        
        // case where we may have deleted dialog from another device
        if( response.status != QBResponseStatusCodeNotFound ) {
            [weakSelf.serviceManager handleErrorResponse:response];
        }
        
        
        if (completion) {
            completion(response, nil);
        }
        
    }];
}

#pragma mark - Fetch dialogs

- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion {
    
    // checking memory storage for dialog with specific id
    QBChatDialog *dialogFromMemoryStorage = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    if (dialogFromMemoryStorage != nil) {
        if (completion) {
            completion(dialogFromMemoryStorage);
        }
        return;
    }
    
    // checking cache for dialog with specific id
    if ([self.cacheDataSource respondsToSelector:@selector(cachedDialogWithID:completion:)]) {
        NSAssert(self.serviceManager.currentUser != nil, @"Current user must be non nil!");
        
        [self.cacheDataSource cachedDialogWithID:dialogID completion:^(QBChatDialog *dialog) {
            if (completion) completion(dialog);
        }];
    }
    else {
        if (completion) {
            completion(nil);
        }
    }
}

- (void)loadDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *loadedDialog))completion {
    __weak __typeof(self)weakSelf = self;
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:1 skip:0];
    NSMutableDictionary *extendedRequest = @{@"_id":dialogID}.mutableCopy;
    [QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        if ([dialogObjects firstObject] != nil) {
            [weakSelf.dialogsMemoryStorage addChatDialog:[dialogObjects firstObject] andJoin:self.isAutoJoinEnabled completion:nil];
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogToMemoryStorage:[dialogObjects firstObject]];
            }
        }
        if (completion) {
            completion([dialogObjects firstObject]);
        }
    } errorBlock:^(QBResponse *response) {
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)fetchDialogsUpdatedFromDate:(NSDate *)date andPageLimit:(NSUInteger)limit iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iteration completionBlock:(void (^)(QBResponse *response))completion {
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSMutableDictionary *extendedRequest = @{@"updated_at[gte]":@(timeInterval)}.mutableCopy;
    
    [self allDialogsWithPageLimit:limit extendedRequest:extendedRequest iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        //
        if (iteration) iteration(response, dialogObjects, dialogsUsersIDs, stop);
    } completion:^(QBResponse *response) {
        //
        if (completion){
            completion(response);
        }
    }];
}

#pragma mark - Send messages

- (void)sendMessage:(QBChatMessage *)message
               type:(QMMessageType)type
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion
{
    message.dateSent = [NSDate date];
    
    //Save to history
    if (saveToHistory) {
        message.saveToHistory = kChatServiceSaveToHistoryTrue;
    }
    //Set message type
    if (type != QMMessageTypeText) {
        message.messageType = type;
    }
    
    QBUUser *currentUser = self.serviceManager.currentUser;
    
    if (dialog.type == QBChatDialogTypePrivate) {
        message.recipientID = dialog.recipientID;
        message.markable = YES;
    }
    
    message.senderID = currentUser.ID;
    message.dialogID = dialog.ID;
    
    __weak __typeof(self)weakSelf = self;
    [dialog sendMessage:message completionBlock:^(NSError *error) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        // there is a case when message that was returned from server (Group dialogs)
        // will be handled faster then this completion block been fired
        // therefore there is no need to add local message to memory storage, while server
        // up-to-date one is already there
        BOOL messageExists = [strongSelf.messagesMemoryStorage isMessageExistent:message forDialogID:message.dialogID];
        
        if (error == nil && !messageExists && saveToStorage) {
            
            [strongSelf.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
            
            if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
                [strongSelf.multicastDelegate chatService:strongSelf didAddMessageToMemoryStorage:message forDialogID:dialog.ID];
            }
            
            [strongSelf updateLastMessageParamsForChatDialog:dialog withMessage:message];
            dialog.updatedAt = message.dateSent;
            
            if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [strongSelf.multicastDelegate chatService:strongSelf didUpdateChatDialogInMemoryStorage:dialog];
            }
        }
        
        if (completion) completion(error);
    }];
}

- (void)sendMessage:(QBChatMessage *)message
         toDialogID:(NSString *)dialogID
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion
{
    NSCParameterAssert(dialogID);
    QBChatDialog *dialog = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    NSAssert(dialog != nil, @"Dialog have to be in memory cache!");
    
    [self sendMessage:message toDialog:dialog saveToHistory:saveToHistory saveToStorage:saveToStorage completion:completion];
}

- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion
{
    NSAssert(message.messageType == QMMessageTypeText, @"You can only send text messages with this method.");
    
    [self sendMessage:message type:QMMessageTypeText toDialog:dialog saveToHistory:saveToHistory saveToStorage:saveToStorage completion:completion];
}

- (void)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                     toDialog:(QBChatDialog *)dialog
          withAttachmentImage:(UIImage *)image
                   completion:(QBChatCompletionBlock)completion
{
    
    [self.messagesMemoryStorage addMessage:attachmentMessage forDialogID:dialog.ID];
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
        
        [self.multicastDelegate chatService:self didAddMessageToMemoryStorage:attachmentMessage forDialogID:dialog.ID];
        
    }
    
    [self.chatAttachmentService uploadAndSendAttachmentMessage:attachmentMessage toDialog:dialog withChatService:self withAttachedImage:image completion:^(NSError* QB_NULLABLE_S error) {
        
        if (!error) {
            
            [self updateLastMessageParamsForChatDialog:dialog withMessage:attachmentMessage];
            dialog.updatedAt = attachmentMessage.dateSent;
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:dialog];
            }
        }
        
        if (completion) {
            completion(error);
        }
    }];

}

#pragma mark - mark as delivered

- (void)markMessageAsDelivered:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion {
    [self markMessagesAsDelivered:@[message] completion:completion];
}

- (void)markMessagesAsDelivered:(NSArray *)messages completion:(QBChatCompletionBlock)completion {
    
    dispatch_group_t deliveredGroup = dispatch_group_create();
    
    for (QBChatMessage *message in messages) {
        
        if (message.senderID == self.serviceManager.currentUser.ID || message.isNotificatonMessage) {
            // no need to mark self or notifications messages as delivered
            continue;
        }
        
        if (![message.deliveredIDs containsObject:@(self.serviceManager.currentUser.ID)]) {
            
            message.markable = YES;
            
            dispatch_group_enter(deliveredGroup);
            
            __weak __typeof(self)weakSelf = self;
            [[QBChat instance] markAsDelivered:message completion:^(NSError *error) {
                
                __typeof(weakSelf)strongSelf = weakSelf;
                if (error == nil) {
                    // updating message in memory storage
                    [strongSelf.messagesMemoryStorage addMessage:message forDialogID:message.dialogID];
                    
                    if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                        
                        [strongSelf.multicastDelegate chatService:strongSelf didUpdateMessage:message forDialogID:message.dialogID];
                    }
                }
                
                dispatch_group_leave(deliveredGroup);
            }];
        }
    }
    
    dispatch_group_notify(deliveredGroup, dispatch_get_main_queue(), ^{
        
        if (completion) {
            
            completion(nil);
        }
    });
}

#pragma mark - read messages

- (void)readMessage:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion {
    NSAssert(message.dialogID != nil, @"Message must have a dialog ID!");
    
    [self readMessages:@[message] forDialogID:message.dialogID completion:completion];
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID completion:(QBChatCompletionBlock)completion {
    NSAssert(dialogID != nil, @"dialogID can't be nil");
    
    QBChatDialog *chatDialogToUpdate = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    NSAssert(chatDialogToUpdate != nil, @"Dialog wasn't found in memory storage!");

    NSMutableArray *updatedMessages = [NSMutableArray arrayWithCapacity:messages.count];
    
    __weak __typeof(self)weakSelf = self;
    
    dispatch_group_t readGroup = dispatch_group_create();
    
    for (QBChatMessage *message in messages) {
        NSAssert([message.dialogID isEqualToString:dialogID], @"Message is from incorrect dialog.");
        
        if ([message.readIDs containsObject:@(self.serviceManager.currentUser.ID)]) {
            
            continue;
        }
        
        if ([self.messagesToRead containsObject:message.ID]) {
            
            continue;
        }
        
        [self.messagesToRead addObject:message.ID];
        message.markable = YES;
        
        dispatch_group_enter(readGroup);
        [[QBChat instance] readMessage:message completion:^(NSError *error) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if (error == nil) {
                
                if (chatDialogToUpdate.unreadMessagesCount > 0) {
                    
                    chatDialogToUpdate.unreadMessagesCount--;
                }
                
                // updating dialog in cache
                if (chatDialogToUpdate != nil) {
                    
                    if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                        
                        [strongSelf.multicastDelegate chatService:strongSelf didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
                    }
                }
                
                // updating message in memory storage
                [strongSelf.messagesMemoryStorage updateMessage:message];
                
                [updatedMessages addObject:message];
            }
            
            [strongSelf.messagesToRead removeObject:message.ID];
            dispatch_group_leave(readGroup);
        }];
    }
    
    dispatch_group_notify(readGroup, dispatch_get_main_queue(), ^{
        
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessages:forDialogID:)]) {
            
            [strongSelf.multicastDelegate chatService:strongSelf didUpdateMessages:updatedMessages.copy forDialogID:dialogID];
        }
        
        if (completion) {
            
            completion(nil);
        }
    });
}

#pragma mark - QMMemoryStorageProtocol

- (void)free {
    
    [self.loadedAllMessages removeAllObjects];
    [self.lastMessagesLoadDate removeAllObjects];
    [self.messagesMemoryStorage free];
    [self.dialogsMemoryStorage free];
    [self.messagesToRead removeAllObjects];
}

#pragma mark - System messages

- (void)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                  toUsersIDs:(NSArray *)usersIDs
                                    withText:(NSString *)text
                                  completion:(QBChatCompletionBlock)completion {
    
    dispatch_group_t notifyGroup = dispatch_group_create();
    
    for (NSNumber *occupantID in usersIDs) {
        
        if (self.serviceManager.currentUser.ID == [occupantID integerValue]) {
            continue;
        }
        
        QBChatMessage *privateMessage = [self systemMessageWithRecipientID:[occupantID integerValue]
                                                                  withText:text
                                                                parameters:nil];
        
        privateMessage.messageType = QMMessageTypeCreateGroupDialog;
        [privateMessage updateCustomParametersWithDialog:chatDialog];
        
        dispatch_group_enter(notifyGroup);
        [[QBChat instance] sendSystemMessage:privateMessage completion:^(NSError *error) {
            
            dispatch_group_leave(notifyGroup);
        }];
    }
    
    dispatch_group_notify(notifyGroup, dispatch_get_main_queue(), ^{
        
        if (completion) completion(nil);
    });
    
}
- (void)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                  toUsersIDs:(NSArray *)usersIDs
                                  completion:(QBChatCompletionBlock)completion
{
    [self sendSystemMessageAboutAddingToDialog:chatDialog
                                    toUsersIDs:usersIDs
                                      withText:nil
                                    completion:completion];
}

- (void)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                   toOpponentID:(NSUInteger)opponentID
                                     completion:(QBChatCompletionBlock)completion
{
    QBChatMessage *message = [QBChatMessage message];
    message.text = @"Contact request";
    
    QMMessageType messageType = accept ? QMMessageTypeAcceptContactRequest : QMMessageTypeRejectContactRequest;
    
    QBChatDialog *p2pDialog = [self.dialogsMemoryStorage privateChatDialogWithOpponentID:opponentID];
    NSParameterAssert(p2pDialog);
    
    [self sendMessage:message type:messageType toDialog:p2pDialog saveToHistory:YES saveToStorage:YES completion:completion];
}

#pragma mark - Notification messages

- (void)sendNotificationMessageAboutAddingOccupants:(NSArray *)occupantsIDs
                                           toDialog:(QBChatDialog *)chatDialog
                               withNotificationText:(NSString *)notificationText
                                         completion:(QBChatCompletionBlock)completion
{
    QBChatMessage *notificationMessage = [self notificationMessageAboutUpdateDialogWithType:QMDialogUpdateTypeOccupants
                                                                           notificationText:notificationText
                                                                            dialogUpdatedAt:chatDialog.updatedAt];
    notificationMessage.addedOccupantsIDs = occupantsIDs;
    notificationMessage.currentOccupantsIDs = chatDialog.occupantIDs;
    
    [self sendMessage:notificationMessage type:QMMessageTypeUpdateGroupDialog toDialog:chatDialog saveToHistory:YES saveToStorage:YES completion:completion];
}

- (void)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                             withNotificationText:(NSString *)notificationText
                                       completion:(QBChatCompletionBlock)completion
{
    QBChatMessage *notificationMessage = [self notificationMessageAboutUpdateDialogWithType:QMDialogUpdateTypeOccupants
                                                                           notificationText:notificationText
                                                                            dialogUpdatedAt:[NSDate date]];
    notificationMessage.deletedOccupantsIDs = @[@(self.serviceManager.currentUser.ID)];
    
    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray arrayWithArray:chatDialog.occupantIDs];
    [occupantsWithoutCurrentUser removeObject:@(self.serviceManager.currentUser.ID)];
    
    notificationMessage.currentOccupantsIDs = [occupantsWithoutCurrentUser copy];
    
    [self sendMessage:notificationMessage type:QMMessageTypeUpdateGroupDialog toDialog:chatDialog saveToHistory:YES saveToStorage:NO completion:completion];
}

- (void)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText
                                             completion:(QBChatCompletionBlock)completion
{
    QBChatMessage *notificationMessage = [self notificationMessageAboutUpdateDialogWithType:QMDialogUpdateTypePhoto
                                                                           notificationText:notificationText
                                                                            dialogUpdatedAt:chatDialog.updatedAt];
    notificationMessage.dialogPhoto = chatDialog.photo;
    
    [self sendMessage:notificationMessage type:QMMessageTypeUpdateGroupDialog toDialog:chatDialog saveToHistory:YES saveToStorage:YES completion:completion];
}

- (void)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                  withNotificationText:(NSString *)notificationText
                                            completion:(QBChatCompletionBlock)completion
{
    QBChatMessage *notificationMessage = [self notificationMessageAboutUpdateDialogWithType:QMDialogUpdateTypeName
                                                                           notificationText:notificationText
                                                                            dialogUpdatedAt:chatDialog.updatedAt];
    notificationMessage.dialogName = chatDialog.name;
    
    [self sendMessage:notificationMessage type:QMMessageTypeUpdateGroupDialog toDialog:chatDialog saveToHistory:YES saveToStorage:YES completion:completion];
}

#pragma mark - Utilites and helpers

- (QBChatMessage *)privateMessageWithRecipientID:(NSUInteger)recipientID text:(NSString *)text save:(BOOL)save {
    
    QBChatMessage *message = [QBChatMessage message];
    message.recipientID = recipientID;
    message.senderID = self.serviceManager.currentUser.ID;
    message.text = text;
    message.dateSent = [NSDate date];
    
    if (save) {
        message.saveToHistory = kChatServiceSaveToHistoryTrue;
    }
    
    return message;
}

- (QBChatMessage *)systemMessageWithRecipientID:(NSUInteger)recipientID withText:(NSString*)text parameters:(NSDictionary *)paramters {
    
    QBChatMessage *message = [QBChatMessage message];
    message.recipientID = recipientID;
    message.senderID = self.serviceManager.currentUser.ID;
    if (text) {
        message.text = text;
    }
    if (paramters) {
        [message.customParameters addEntriesFromDictionary:paramters];
    }
    
    return message;
    
}


- (QBChatMessage *)notificationMessageAboutUpdateDialogWithType:(QMDialogUpdateType)dialogUpdateType
                                               notificationText:(NSString *)notificationText
                                                dialogUpdatedAt:(NSDate *)dialogUpdatedAt {
    
    QBChatMessage *notificationMessage = [QBChatMessage message];
    notificationMessage.senderID = self.serviceManager.currentUser.ID;
    notificationMessage.text = notificationText;
    notificationMessage.dialogUpdateType = dialogUpdateType;
    notificationMessage.dialogUpdatedAt = dialogUpdatedAt;
    
    return notificationMessage;
}

- (void)updateLastMessageParamsForChatDialog:(QBChatDialog *)dialog
                                 withMessage:(QBChatMessage *)message {
    
    dialog.lastMessageUserID = message.senderID;
    dialog.lastMessageText = message.text;
    dialog.lastMessageDate = message.dateSent;
}

@end
