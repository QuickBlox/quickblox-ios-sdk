//
//  QMChatService.m
//  QMServices
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QBChatMessage+TextEncoding.h"
#import "NSString+GTMNSStringHTMLAdditions.h"
#import "QBChatMessage+QMCustomParameters.h"

const char *kChatCacheQueue = "com.q-municate.chatCacheQueue";


#define kChatServiceSaveToHistoryTrue @"1"

@interface QMChatService() <QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMChatServiceDelegate, QMChatConnectionDelegate> *multicastDelegate;
@property (weak, nonatomic) id <QMChatServiceCacheDataSource> cacheDataSource;
@property (strong, nonatomic) QMDialogsMemoryStorage *dialogsMemoryStorage;
@property (strong, nonatomic) QMMessagesMemoryStorage *messagesMemoryStorage;
@property (strong, nonatomic) QMChatAttachmentService *chatAttachmentService;
@property (strong, nonatomic, readonly) NSNumber *dateSendTimeInterval;

@property (strong, nonatomic) NSTimer *presenceTimer;

@end

@implementation QMChatService

@dynamic dateSendTimeInterval;

- (void)dealloc {
	
	NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
	
	[self.presenceTimer invalidate];
	[QBChat.instance removeDelegate:self];
}

#pragma mark - Configure

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager cacheDataSource:(id<QMChatServiceCacheDataSource>)cacheDataSource {
	
	self = [super initWithServiceManager:serviceManager];
	
	if (self) {
		
		self.cacheDataSource = cacheDataSource;
		
		self.presenceTimerInterval = 45.0;
		self.automaticallySendPresences = YES;
        
        if ([QBSession currentSession].currentUser != nil) [self loadCachedDialogsWithCompletion:nil];
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

#pragma mark - Getters

- (NSNumber *)dateSendTimeInterval {
	
	return @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
}

#pragma mark - Load cached data

- (void)loadCachedDialogsWithCompletion:(void(^)())completion
{
    __weak __typeof(self)weakSelf = self;
	
	if ([self.cacheDataSource respondsToSelector:@selector(cachedDialogs:)]) {
        
        NSAssert([QBSession currentSession].currentUser != nil, @"Current user must be non nil!");
		
		[weakSelf.cacheDataSource cachedDialogs:^(NSArray *collection) {
			// We need only current users dialog
            NSArray* userDialogs = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%lu IN self.occupantIDs", [QBSession currentSession].currentUser.ID]];
            
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
            
            if (completion) {
                completion();
            }
		}];
	}
}

- (void)loadCahcedMessagesWithDialogID:(NSString *)dialogID compleion:(dispatch_block_t)completion {
	
	if ([self.cacheDataSource respondsToSelector:@selector(cachedMessagesWithDialogID:block:)]) {
		
		__weak __typeof(self)weakSelf = self;
		[self.cacheDataSource cachedMessagesWithDialogID:dialogID block:^(NSArray *collection) {
			
			if (collection.count > 0) {
				
				[weakSelf.messagesMemoryStorage replaceMessages:collection forDialogID:dialogID];
				
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

- (void)chatDidLogin {
	
	if (self.automaticallySendPresences){
		[self startSendPresence];
	}
    
    [QBChat.instance setCarbonsEnabled:YES];
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidLogin)]) {
        [self.multicastDelegate chatServiceChatDidLogin];
    }
}

- (void)chatDidNotLoginWithError:(NSError *)error {
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidNotLoginWithError:)]) {
        [self.multicastDelegate chatServiceChatDidNotLoginWithError:error];
    }
}

- (void)chatDidFailWithStreamError:(NSError *)error {
	
	[self stopSendPresence];
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidFailWithStreamError:)]) {
        [self.multicastDelegate chatServiceChatDidFailWithStreamError:error];
    }
}

- (void)chatDidConnect
{
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidConnect:)]) {
        [self.multicastDelegate chatServiceChatDidConnect:self];
    }
}

- (void)chatDidAccidentallyDisconnect
{
    if ([self.multicastDelegate respondsToSelector:@selector(chatServiceChatDidAccidentallyDisconnect:)]) {
        [self.multicastDelegate chatServiceChatDidAccidentallyDisconnect:self];
    }
}

- (void)chatDidReconnect
{
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

- (void)logIn:(QBChatCompletionBlock)completion {
	
	BOOL isAuthorized = self.serviceManager.isAuthorized;
	NSAssert(isAuthorized, @"User must be authorized");
	
	QBUUser *user = self.serviceManager.currentUser;
    NSAssert(user != nil, @"User must be already allocated!");
	
	if (QBChat.instance.isConnected) {
		if(completion){
			completion(nil);
		}
	}
	else {
        [QBSettings setAutoReconnectEnabled:YES];
        [[QBChat instance] connectWithUser:user completion:completion];
	}
}

- (void)connectWithCompletionBlock:(QBChatCompletionBlock)completion {
    [self logIn:completion];
}

- (void)logoutChat {
	
	[self stopSendPresence];
	
	if (QBChat.instance.isConnected) {
		[QBChat.instance disconnect];
	}
}

- (void)disconnectWithCompletionBlock:(QBChatCompletionBlock)completion {
    
    [self stopSendPresence];
    [[QBChat instance] disconnectWithCompletionBlock:completion];
}

#pragma mark - Presence

- (void)startSendPresence {
	
	[self sendPresence:nil];
	
	self.presenceTimer =
	[NSTimer scheduledTimerWithTimeInterval:self.presenceTimerInterval
									 target:self
								   selector:@selector(sendPresence:)
								   userInfo:nil
									repeats:YES];
}

- (void)sendPresence:(NSTimer *)timer {
	
	[QBChat.instance sendPresence];
}

- (void)stopSendPresence {
	
	[self.presenceTimer invalidate];
	self.presenceTimer = nil;
}

#pragma mark - Handle Chat messages

- (void)handleSystemMessage:(QBChatMessage *)message {
    
    if (message.messageType == QMMessageTypeCreateGroupDialog) {
        __weak __typeof(self)weakSelf = self;
        
        [self.dialogsMemoryStorage addChatDialog:message.dialog andJoin:YES completion:^(NSError * _Nullable error) {
            //
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogToMemoryStorage:message.dialog];
            }
        }];
    }
}

- (void)handleChatMessage:(QBChatMessage *)message {
	
    if (!message.dialogID) {
        
        NSLog(@"Need update this case");
        
        return;
    }
    
    QBChatDialog *chatDialogToUpdate = [self.dialogsMemoryStorage chatDialogWithID:message.dialogID];
	
	if (message.messageType == QMMessageTypeText) {
        BOOL shouldSaveDialog = NO;
        
		//Update chat dialog in memory storage
        if (!chatDialogToUpdate)
        {
            chatDialogToUpdate = [[QBChatDialog alloc] initWithDialogID:message.dialogID type:QBChatDialogTypePrivate];
            chatDialogToUpdate.occupantIDs = @[@([self.serviceManager currentUser].ID), @(message.senderID)];
            
            shouldSaveDialog = YES;
        }
        
		chatDialogToUpdate.lastMessageText = message.encodedText;
		chatDialogToUpdate.lastMessageDate = message.dateSent;
        chatDialogToUpdate.updatedAt = message.dateSent;
        
        if (message.senderID != [QBSession currentSession].currentUser.ID) {
            chatDialogToUpdate.unreadMessagesCount++;
        }
        
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
	else if (message.messageType == QMMessageTypeUpdateGroupDialog) {

        if (chatDialogToUpdate) {
//        if (!chatDialogToUpdate.updatedAt || [chatDialogToUpdate.updatedAt compare:message.dialog.updatedAt] == NSOrderedAscending) {
            chatDialogToUpdate.name = message.dialog.name;
            chatDialogToUpdate.photo = message.dialog.photo;
            chatDialogToUpdate.occupantIDs = message.dialog.occupantIDs;
            chatDialogToUpdate.lastMessageText = message.encodedText;
            chatDialogToUpdate.lastMessageDate = message.dateSent;
            chatDialogToUpdate.updatedAt = message.dateSent;
            chatDialogToUpdate.unreadMessagesCount++;
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
            }
//        }
        }
	}
    else if (message.messageType == QMMessageTypeContactRequest || message.messageType == QMMessageTypeAcceptContactRequest || message.messageType == QMMessageTypeRejectContactRequest || message.messageType == QMMessageTypeDeleteContactRequest) {

        if (chatDialogToUpdate != nil) {
            chatDialogToUpdate.lastMessageText = message.encodedText;
            chatDialogToUpdate.lastMessageDate = message.dateSent;
            chatDialogToUpdate.updatedAt = message.dateSent;
            chatDialogToUpdate.unreadMessagesCount++;
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
            }
        }
        else {
            chatDialogToUpdate = [[QBChatDialog alloc] initWithDialogID:message.dialogID type:QBChatDialogTypePrivate];
            chatDialogToUpdate.occupantIDs = @[@([self.serviceManager currentUser].ID), @(message.senderID)];
            chatDialogToUpdate.lastMessageText = message.encodedText;
            chatDialogToUpdate.lastMessageDate = message.dateSent;
            chatDialogToUpdate.updatedAt = message.dateSent;
            chatDialogToUpdate.unreadMessagesCount++;
            
            [self.dialogsMemoryStorage addChatDialog:chatDialogToUpdate andJoin:NO completion:nil];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didAddChatDialogToMemoryStorage:chatDialogToUpdate];
            }
        }
	}
	
	if ([message.saveToHistory isEqualToString:kChatServiceSaveToHistoryTrue]) {
		
		[self.messagesMemoryStorage addMessage:message forDialogID:message.dialogID];
		
		if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
			[self.multicastDelegate chatService:self didAddMessageToMemoryStorage:message forDialogID:message.dialogID];
		}
	}
    
    if (message.isNotificatonMessage && chatDialogToUpdate != nil) {
        if ([self.multicastDelegate respondsToSelector:@selector(chatService:didReceiveNotificationMessage:createDialog:)]) {
            [self.multicastDelegate chatService:self didReceiveNotificationMessage:message createDialog:chatDialogToUpdate];
        }
    }
}

- (void)joinToGroupDialog:(QBChatDialog *)dialog
               failed:(void (^)(NSError *))failed {
    
    NSParameterAssert(dialog.type != QBChatDialogTypePrivate);
    
    if (dialog.isJoined) {
        return;
    }
    
    NSString *dialogID = dialog.ID;
    
    [dialog setOnJoinFailed:^(NSError *error) {
        
        if (error.code == 201 || error.code == 404 || error.code == 407) {
            
            [self.dialogsMemoryStorage deleteChatDialogWithID:dialogID];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didDeleteChatDialogWithIDFromMemoryStorage:dialogID];
            }
        }
        
        if (failed) {
            failed(error);
        }
        
    }];
    
    [dialog join];
}

- (void)joinToGroupDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion {
    
    NSParameterAssert(dialog.type != QBChatDialogTypePrivate);
    
    if (dialog.isJoined) {
        return;
    }
    
    NSString *dialogID = dialog.ID;
    
    [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
        //
        if (error != nil) {
            if (error.code == 201 || error.code == 404 || error.code == 407) {
                
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
				iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))interationBlock
					 completion:(void(^)(QBResponse *response))completion {
	
	__weak __typeof(self)weakSelf = self;
	
	__block QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:limit];
	__block BOOL cancel = NO;
	
	__block dispatch_block_t t_request;
	
	dispatch_block_t request = [^{
        
        if (![weakSelf.serviceManager isAuthorized]) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        
		[QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            
			[weakSelf.dialogsMemoryStorage addChatDialogs:dialogObjects andJoin:YES];
			
			if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogsToMemoryStorage:)]) {
				[weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogsToMemoryStorage:dialogObjects];
			}
			
			responsePage.skip += dialogObjects.count;
			
			if (page.totalEntries <= responsePage.skip) {
				cancel = YES;
			}
			
			interationBlock(response, dialogObjects, dialogsUsersIDs, &cancel);
            
            if (!cancel) {
				t_request();
			} else {
                if (completion) {
					completion(response);
				}
			}
			
		} errorBlock:^(QBResponse *response) {

			[weakSelf.serviceManager handleErrorResponse:response];
			
			if (completion) {
				completion(response);
			}
		}];
		
	} copy];
	
	t_request = request;
	request();
}

#pragma mark - Create Private/Group dialog

- (void)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID
                                 completion:(void(^)(QBResponse *response, QBChatDialog *createdDialo))completion {
    
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

        [weakSelf.dialogsMemoryStorage addChatDialog:createdDialog andJoin:YES completion:^(NSError * _Nullable error) {
            //
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddChatDialogToMemoryStorage:)]) {
                [weakSelf.multicastDelegate chatService:weakSelf didAddChatDialogToMemoryStorage:createdDialog];
            }
            
            if (completion) {
                completion(response, createdDialog);
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
        
        [weakSelf.dialogsMemoryStorage addChatDialog:updatedDialog andJoin:YES completion:^(NSError * _Nullable error) {
            //
            if (completion) {
                completion(response, updatedDialog);
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
        [weakSelf.dialogsMemoryStorage addChatDialog:dialog andJoin:YES completion:^(NSError * _Nullable error) {
            //
            if (completion) completion(response,dialog);
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

        [weakSelf.dialogsMemoryStorage addChatDialog:updatedDialog andJoin:YES completion:^(NSError * _Nullable error) {
            //
            if (completion) {
                completion(response, updatedDialog);
            }
        }];
		
	} errorBlock:^(QBResponse *response) {
		
		[weakSelf.serviceManager handleErrorResponse:response];
		
		if (completion) {
			completion(response, nil);
		}
	}];
}

- (void)deleteDialogWithID:(NSString *)dialogId completion:(void (^)(QBResponse *))completion {
	
    NSParameterAssert(dialogId);
    
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:dialogId] forAllUsers:NO successBlock:^(QBResponse * _Nonnull response, NSArray<NSString *> * _Nullable deletedObjectsIDs, NSArray<NSString *> * _Nullable notFoundObjectsIDs, NSArray<NSString *> * _Nullable wrongPermissionsObjectsIDs) {
        //
        [weakSelf.dialogsMemoryStorage deleteChatDialogWithID:dialogId];
        [weakSelf.messagesMemoryStorage deleteMessagesWithDialogID:dialogId];
        
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didDeleteChatDialogWithIDFromMemoryStorage:)]) {
            [weakSelf.multicastDelegate chatService:weakSelf didDeleteChatDialogWithIDFromMemoryStorage:dialogId];
        }
        
        if (completion) {
            completion(response);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        //
        if (response.status == QBResponseStatusCodeNotFound) {
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

- (void)messagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion {
	
    __weak __typeof(self) weakSelf = self;
    
	[self loadCahcedMessagesWithDialogID:chatDialogID compleion:^{
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:kQMChatMessagesPerPage];
        
        NSMutableDictionary* parameters = [@{@"sort_desc" : @"date_sent"} mutableCopy];
        
        QBChatMessage* lastMessage = [weakSelf.messagesMemoryStorage lastMessageFromDialogID:chatDialogID];
        
        if (lastMessage != nil) {
            parameters[@"date_sent[gt]"] = @([lastMessage.dateSent timeIntervalSince1970]);
        }
        
        [QBRequest messagesWithDialogID:chatDialogID
                        extendedRequest:parameters
                                forPage:page
                           successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
                               NSArray* sortedMessages = [[messages reverseObjectEnumerator] allObjects];
                               
                               if ([sortedMessages count] > 0) {
        
                                   if (lastMessage == nil) {
                                       [weakSelf.messagesMemoryStorage replaceMessages:sortedMessages forDialogID:chatDialogID];
                                   } else {
                                       [weakSelf.messagesMemoryStorage addMessages:sortedMessages forDialogID:chatDialogID];
                                   }
                                   
                                   if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didAddMessagesToMemoryStorage:forDialogID:)]) {
                                       [weakSelf.multicastDelegate chatService:weakSelf didAddMessagesToMemoryStorage:sortedMessages forDialogID:chatDialogID];
                                   }
                               }
                               
                               if (completion) {
                                   completion(response, sortedMessages);
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
    }];
}

- (void)earlierMessagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion {
    
    if ([self.messagesMemoryStorage isEmptyForDialogID:chatDialogID]) {
        
        [self messagesWithChatDialogID:chatDialogID completion:completion];
        
        return;
    }
    
    QBChatMessage *oldestMessage = [self.messagesMemoryStorage oldestMessageForDialogID:chatDialogID];
    NSString *oldestMessageDate = [NSString stringWithFormat:@"%ld", (long)[oldestMessage.dateSent timeIntervalSince1970]];
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:kQMChatMessagesPerPage];
    
    __weak __typeof(self) weakSelf = self;
    
    [QBRequest messagesWithDialogID:chatDialogID extendedRequest:@{@"date_sent[lt]": oldestMessageDate, @"sort_desc" : @"date_sent"} forPage:page successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        
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

- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion
{
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
        NSAssert([QBSession currentSession].currentUser != nil, @"Current user must be non nil!");
        
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
            [weakSelf.dialogsMemoryStorage addChatDialog:[dialogObjects firstObject] andJoin:YES completion:nil];
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

- (void)fetchDialogsUpdatedFromDate:(NSDate *)date
                       andPageLimit:(NSUInteger)limit
                     iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iteration
                    completionBlock:(void (^)(QBResponse *response))completion
{
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSMutableDictionary *extendedRequest = @{@"updated_at[gt]":@(timeInterval)}.mutableCopy;
    
    [self allDialogsWithPageLimit:limit extendedRequest:extendedRequest iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        //
        if (iteration) iteration(response,dialogObjects,dialogsUsersIDs,stop);
    } completion:^(QBResponse *response) {
        //
        if (completion) completion(response);
    }];
}

#pragma mark - Send messages

- (BOOL)sendMessage:(QBChatMessage *)message type:(QMMessageType)type toDialog:(QBChatDialog *)dialog save:(BOOL)save completion:(void(^)(NSError *error))completion {
	
    return [self sendMessage:message type:type toDialog:dialog save:save saveToStorage:YES completion:completion];
}

- (BOOL)sendMessage:(QBChatMessage *)message type:(QMMessageType)type toDialog:(QBChatDialog *)dialog save:(BOOL)save saveToStorage:(BOOL)saveToStorage completion:(void(^)(NSError *error))completion {
    
    message.customDateSent = self.dateSendTimeInterval;
    
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    //Save to history
    if (save) {
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
    
    dialog.lastMessageText = message.encodedText;
    dialog.lastMessageDate = message.dateSent;
    dialog.updatedAt = message.dateSent;
    
    BOOL messageSent = [dialog sendMessage:message sentBlock:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
    
    if (messageSent) {
        if (saveToStorage) {
            [self.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
                [self.multicastDelegate chatService:self didAddMessageToMemoryStorage:message forDialogID:dialog.ID];
            }
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:dialog];
            }
        }
    }
    
    return messageSent;
}

- (BOOL)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog save:(BOOL)save completion:(void(^)(NSError *error))completion {
	
	return [self sendMessage:message type:QMMessageTypeText toDialog:dialog save:save completion:completion];
}

- (BOOL)sendMessage:(QBChatMessage *)message toDialogId:(NSString *)dialogID save:(BOOL)save completion:(void (^)(NSError *))completion
{
    NSCParameterAssert(dialogID);
    QBChatDialog *dialog = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    NSAssert(dialog != nil, @"Dialog have to be in memory cache!");
    
    return [self sendMessage:message toDialog:dialog save:YES completion:completion];
}

- (void)sendMessage:(QBChatMessage *)message
               type:(QMMessageType)type
         toDialogID:(NSString *)dialogID
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion
{
    NSCParameterAssert(dialogID);
    QBChatDialog *dialog = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    NSAssert(dialog != nil, @"Dialog have to be in memory cache!");
    
    [self sendMessage:message type:type toDialog:dialog saveToHistory:saveToHistory saveToStorage:saveToStorage completion:completion];
}

- (void)sendMessage:(QBChatMessage *)message
               type:(QMMessageType)type
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion
{
    message.customDateSent = self.dateSendTimeInterval;
    
    message.text = [message.text gtm_stringByEscapingForHTML];
    
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
    
    dialog.lastMessageText = message.encodedText;
    dialog.lastMessageDate = message.dateSent;
    dialog.updatedAt = message.dateSent;

    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        //
        if (error == nil && saveToStorage) {
            [self.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didAddMessageToMemoryStorage:forDialogID:)]) {
                [self.multicastDelegate chatService:self didAddMessageToMemoryStorage:message forDialogID:dialog.ID];
            }
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
                [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:dialog];
            }
        }
        
        if (completion) completion(error);
    }];
}

#pragma mark - read messages

- (BOOL)readMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    return [self readMessages:@[message] forDialogID:dialogID];
}

- (void)readMessage:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion {
    NSAssert(message.dialogID != nil, @"Message must have a dialog ID!");
    
    [self readMessages:@[message] forDialogID:message.dialogID completion:completion];
}

- (BOOL)readMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID {
    NSAssert(dialogID != nil, @"dialogID can't be nil");
    
    if (![QBChat instance].isConnected) return NO;
    
    QBChatDialog *chatDialogToUpdate = [self.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    for (QBChatMessage *message in messages) {
        message.markable = YES;
        if ([[QBChat instance] readMessage:message]) {
            if (chatDialogToUpdate.unreadMessagesCount > 0) {
                chatDialogToUpdate.unreadMessagesCount--;
            }
            
            if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                [self.multicastDelegate chatService:self didUpdateMessage:message forDialogID:dialogID];
            }
        }
    }
    
    if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
        [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
    }
    
    return YES;
}

- (void)readMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID completion:(QBChatCompletionBlock)completion {
    NSAssert(dialogID != nil, @"dialogID can't be nil");
    
    dispatch_group_t readGroup = dispatch_group_create();
    
    QBChatDialog *chatDialogToUpdate = [self.dialogsMemoryStorage chatDialogWithID:dialogID];

    for (QBChatMessage *message in messages) {
        NSAssert([message.dialogID isEqualToString:dialogID], @"Message is from incorrect dialog.");
        
        if (![message.readIDs containsObject:@([QBSession currentSession].currentUser.ID)]) {
            message.markable = YES;
            __weak __typeof(self)weakSelf = self;
            dispatch_group_enter(readGroup);
            [[QBChat instance] readMessage:message completion:^(NSError * _Nullable error) {
                //
                if (error == nil) {
                    if (chatDialogToUpdate.unreadMessagesCount > 0) {
                        chatDialogToUpdate.unreadMessagesCount--;
                    }
                    
                    if ([weakSelf.multicastDelegate respondsToSelector:@selector(chatService:didUpdateMessage:forDialogID:)]) {
                        [weakSelf.multicastDelegate chatService:weakSelf didUpdateMessage:message forDialogID:dialogID];
                    }
                }
                dispatch_group_leave(readGroup);
            }];
        }
    }
    
    dispatch_group_notify(readGroup, dispatch_get_main_queue(), ^{
        //
        if ([self.multicastDelegate respondsToSelector:@selector(chatService:didUpdateChatDialogInMemoryStorage:)]) {
            [self.multicastDelegate chatService:self didUpdateChatDialogInMemoryStorage:chatDialogToUpdate];
        }
        if (completion) {
            completion(nil);
        }
    });
}

#pragma mark - QMMemoryStorageProtocol

- (void)free {
	
	[self.messagesMemoryStorage free];
	[self.dialogsMemoryStorage free];
}

#pragma mark - System messages

- (void)notifyUsersWithIDs:(NSArray *)usersIDs aboutAddingToDialog:(QBChatDialog *)dialog {
    
    for (NSNumber *occupantID in usersIDs) {
        
        if (self.serviceManager.currentUser.ID == [occupantID integerValue]) {
            continue;
        }
        
        QBChatMessage *privateMessage = [self systemMessageWithRecipientID:[occupantID integerValue] parameters:nil];
        privateMessage.messageType = QMMessageTypeCreateGroupDialog;
        [privateMessage updateCustomParametersWithDialog:dialog];
        
        [[QBChat instance] sendSystemMessage:privateMessage completion:nil];
    }
}

- (void)notifyUsersWithIDs:(NSArray *)usersIDs aboutAddingToDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion {
    
    dispatch_group_t notifyGroup = dispatch_group_create();
    
    for (NSNumber *occupantID in usersIDs) {
        
        if (self.serviceManager.currentUser.ID == [occupantID integerValue]) {
            continue;
        }
        
        QBChatMessage *privateMessage = [self systemMessageWithRecipientID:[occupantID integerValue] parameters:nil];
        privateMessage.messageType = QMMessageTypeCreateGroupDialog;
        [privateMessage updateCustomParametersWithDialog:dialog];
        
        dispatch_group_enter(notifyGroup);
        [[QBChat instance] sendSystemMessage:privateMessage completion:^(NSError * _Nullable error) {
            //
            dispatch_group_leave(notifyGroup);
        }];
    }
    
    dispatch_group_notify(notifyGroup, dispatch_get_main_queue(), ^{
        //
        if (completion) completion(nil);
    });
}

- (void)notifyAboutUpdateDialog:(QBChatDialog *)updatedDialog
      occupantsCustomParameters:(NSDictionary *)occupantsCustomParameters
               notificationText:(NSString *)notificationText
                     completion:(QBChatCompletionBlock)completion {
    
    NSParameterAssert(updatedDialog);
    
    QBChatMessage *message = [QBChatMessage message];
    message.messageType = QMMessageTypeUpdateGroupDialog;
    message.text = notificationText;
    message.saveToHistory = kChatServiceSaveToHistoryTrue;
    
    [message updateCustomParametersWithDialog:updatedDialog];
    
    if (occupantsCustomParameters)
    {
        [message.customParameters addEntriesFromDictionary:occupantsCustomParameters];
    }
    
    [updatedDialog sendMessage:message completionBlock:completion];
}

- (void)notifyOponentAboutAcceptingContactRequest:(BOOL)accept opponentID:(NSUInteger)opponentID completion:(QBChatCompletionBlock)completion {
    
    QBChatMessage *message = [self privateMessageWithRecipientID:opponentID text:@"Contact request" save:YES];
    
    QMMessageType messageType = accept ? QMMessageTypeAcceptContactRequest : QMMessageTypeRejectContactRequest;
    
    QBChatDialog *p2pDialog = [self.dialogsMemoryStorage privateChatDialogWithOpponentID:opponentID];
    NSParameterAssert(p2pDialog);
    
    [self sendMessage:message type:messageType toDialog:p2pDialog saveToHistory:YES saveToStorage:YES completion:completion];
}

#pragma mark System messages Utilites

- (QBChatMessage *)privateMessageWithRecipientID:(NSUInteger)recipientID text:(NSString *)text save:(BOOL)save {
	
	QBChatMessage *message = [QBChatMessage message];
	message.recipientID = recipientID;
	message.senderID = self.serviceManager.currentUser.ID;
    message.text = text;
    message.dateSent = [NSDate date];
	message.customDateSent = self.dateSendTimeInterval;
	
	if (save) {
		message.saveToHistory = kChatServiceSaveToHistoryTrue;
	}
	
	return message;
}

- (QBChatMessage *)systemMessageWithRecipientID:(NSUInteger)recipientID parameters:(NSDictionary *)paramters {
    
    QBChatMessage *message = [QBChatMessage message];
    message.recipientID = recipientID;
    message.senderID = self.serviceManager.currentUser.ID;
    
    if (paramters) {
        [message.customParameters addEntriesFromDictionary:paramters];
    }
    
    return message;
}

@end
