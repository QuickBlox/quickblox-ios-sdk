//
//  QMServiceManager.m
//  QMServices
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMServicesManager.h"
#import "_CDMessage.h"
#import "_CDDialog.h"

#import "QMSLog.h"

@interface QMServicesManager ()

@property (nonatomic, strong) QMAuthService *authService;
@property (nonatomic, strong) QMChatService *chatService;

@property (nonatomic, strong) dispatch_group_t joinGroup;

@end

@implementation QMServicesManager

//MARK: - Logging management

+ (void)enableLogging:(BOOL)flag {
    
    QMSLogSetEnabled(flag);
}

//MARK: - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [QMChatCache setupDBWithStoreNamed:@"sample-cache" applicationGroupIdentifier:[self appGroupIdentifier]];
        QMChatCache.instance.messagesLimitPerDialog = kQMMessagesLimitPerDialog;
        
        _authService = [[QMAuthService alloc] initWithServiceManager:self];
        _chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        [_chatService setChatMessagesPerPage:kQMChatMessagesPerPage];
        [_chatService addDelegate:self];
        
        // Enables auto join handling for group chat dialogs.
        // Remove this or set it to NO if you want to handle group chat dialog joining manually
        // or you are using our Enterprise feature to manage group chat dialogs without join being required.
        _chatService.enableAutoJoin = YES;
        
        [QMUsersCache setupDBWithStoreNamed:@"qb-users-cache" applicationGroupIdentifier:[self appGroupIdentifier]];
        _usersService = [[QMUsersService alloc] initWithServiceManager:self cacheDataSource:self];
        [_usersService addDelegate:self];
        
        _joinGroup = dispatch_group_create();
    }
    
    return self;
}

+ (instancetype)instance {
    
    static QMServicesManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
    });
    
    return manager;
}

//MARK: - Methods

- (void)logoutWithCompletion:(dispatch_block_t)completion {
    
    __weak typeof(self)weakSelf = self;
    [self.chatService disconnectWithCompletionBlock:^(NSError *error) {
        
        [weakSelf.chatService.chatAttachmentService removeAllMediaFiles];
        [weakSelf.chatService free];
        [weakSelf.usersService free];
        
        [QMChatCache.instance truncateAll];
        [QMUsersCache.instance truncateAll];
        
        [QBRequest cancelAllRequests:^{
            
            [self.authService logOut:^(QBResponse * _Nonnull response) {
                if (completion) {
                    completion();
                }
            }];
        }];
    }];
}

- (void)logInWithUser:(QBUUser *)user
           completion:(void (^)(BOOL success, NSString *errorMessage))completion {
    
    [[self.authService loginWithUser:user] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull t) {
        
        if (t.isFaulted) {
            
            if (completion ) {
                completion(NO, t.error.localizedDescription);
            }
        }
        else {
            
            [self.chatService connectWithCompletionBlock:^(NSError *error) {
                
                if (completion) {
                    completion(!error, error.localizedDescription);
                }
            }];
        }
        
        return nil;
    }];
}

- (void)handleErrorResponse:(QBResponse *)response {
    
}

- (NSString *)appGroupIdentifier {
    
    return @"";
}

- (BOOL)isAuthorized {
    
    return self.authService.isAuthorized;
}

- (QBUUser *)currentUser {
    
    return QBSession.currentSession.currentUser;
}

- (void)joinAllGroupDialogsIfNeeded {
    [self joinAllGroupDialogsIfNeededWithCompletion:nil];
}

- (void)joinAllGroupDialogsIfNeededWithCompletion:(dispatch_block_t)completion {
    
    if (!self.chatService.isAutoJoinEnabled) {
        // if auto join is not enabled QMServices will not join group chat dialogs automatically.
        if (completion) {
            completion();
        }
        return;
    }
    
    NSArray *dialogObjects = [self.chatService.dialogsMemoryStorage dialogsSortByUpdatedAtWithAscending:NO];
    
    for (QBChatDialog *dialog in dialogObjects) {
        
        if (dialog.type != QBChatDialogTypePrivate) {
            
            // Joining to group chat dialogs.
            dispatch_group_enter(self.joinGroup);
            
            [self.chatService joinToGroupDialog:dialog completion:^(NSError *error) {
                
                if (error != nil) {
                    QMSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }
                else {
                    [self.chatService.deferredQueueManager performDeferredActionsForDialogWithID:dialog.ID];
                }
                
                dispatch_group_leave(self.joinGroup);
            }];
        }
        else {
            
            [self.chatService.deferredQueueManager performDeferredActionsForDialogWithID:dialog.ID];
        }
    }
    dispatch_group_notify(self.joinGroup, dispatch_get_main_queue(), ^{
        
        if (completion) {
            completion();
        }
    });
}

//MARK: - QMChatServiceDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    
    [self joinAllGroupDialogsIfNeededWithCompletion:NULL];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    
    [self joinAllGroupDialogsIfNeededWithCompletion:NULL];
}

//MARK: QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    
    [QMChatCache.instance insertOrUpdateDialogs:chatDialogs completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray *)dialogs {
    
    [QMChatCache.instance insertOrUpdateDialogs:dialogs completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [self.chatService markMessageAsDelivered:message completion:nil];
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    [self.chatService markMessagesAsDelivered:messages completion:nil];
    [QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
    [QMChatCache.instance deleteMessageWithDialogID:chatDialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteMessageFromMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance deleteMessage:message completion:nil];
    [self.chatService.chatAttachmentService removeMediaFilesForMessageWithID:message.ID
                                                                    dialogID:dialogID];
}

- (void)chatService:(QMChatService *)chatService didDeleteMessagesFromMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance deleteMessages:messages completion:nil];
    
    NSArray *messagesIDs = [messages valueForKeyPath:NSStringFromSelector(@selector(ID))];
    [self.chatService.chatAttachmentService  removeMediaFilesForMessagesWithID:messagesIDs
                                                                      dialogID:dialogID];
}

- (void)chatService:(QMChatService *)chatService
didReceiveNotificationMessage:(QBChatMessage *)message
       createDialog:(QBChatDialog *)dialog {
    
    NSAssert([message.dialogID isEqualToString:dialog.ID], @"must be equal");
    
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
    [QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

//MARK: QMChatServiceCacheDataSource

- (void)cachedDialogs:(QMCacheCollection)block {
    
    NSArray<QBChatDialog *> *dialogs =
    [QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate
                                ascending:YES
                            withPredicate:nil];
    block(dialogs);
}

- (void)cachedDialogsWithPredicate:(NSPredicate *)predicate
                            block:(QMCacheCollection)block {
    
    NSArray<QBChatDialog *> *dialogs =
    [QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate
                                ascending:YES
                            withPredicate:predicate];
    block(dialogs);
}


- (void)cachedDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion {
    
    completion([QMChatCache.instance dialogByID:dialogID]);
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    
    NSArray<QBChatMessage *> *result =
    [QMChatCache.instance messagesWithDialogId:dialogID
                                      sortedBy:CDMessageAttributes.messageID
                                     ascending:NO];
    block(result);
}

- (void)cachedMessagesWithPredicate:(NSPredicate *)predicate
                              block:(nullable QMCacheCollection)block {

    [QMChatCache.instance messagesWithPredicate:predicate
                                       sortedBy:CDMessageAttributes.messageID
                                      ascending:NO
                                     completion:block];
}



//MARK: - QMUsersServiceCacheDataSource

- (void)cachedUsersWithCompletion:(QMCacheCollection)block {
    
    block([QMUsersCache.instance allUsers]);
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray *)users {
    
    [QMUsersCache.instance insertOrUpdateUsers:users];
}

- (void)usersService:(QMUsersService *)usersService didUpdateUsers:(NSArray *)users {
    
    [QMUsersCache.instance insertOrUpdateUsers:users];
}

@end
