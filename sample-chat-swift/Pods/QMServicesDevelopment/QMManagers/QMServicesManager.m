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

/**
 *  Logout group for synchronous completion.
 */
@property (nonatomic, strong) dispatch_group_t logoutGroup;

@property (nonatomic, strong) dispatch_group_t joinGroup;

@end

@implementation QMServicesManager

#pragma mark - Logging management

+ (void)enableLogging:(BOOL)flag {
    
    QMSLogSetEnabled(flag);
}

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [QMChatCache setupDBWithStoreNamed:@"sample-cache"];
        [QMChatCache instance].messagesLimitPerDialog = kQMMessagesLimitPerDialog;
        
        _authService = [[QMAuthService alloc] initWithServiceManager:self];
        _chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        [_chatService setChatMessagesPerPage:kQMChatMessagesPerPage];
        [_chatService addDelegate:self];
        
        // Enables auto join handling for group chat dialogs.
        // Remove this or set it to NO if you want to handle group chat dialog joining manually
        // or you are using our Enterprise feature to manage group chat dialogs without join being required.
        _chatService.enableAutoJoin = YES;
        
        [QMUsersCache setupDBWithStoreNamed:@"qb-users-cache"];
        _usersService = [[QMUsersService alloc] initWithServiceManager:self cacheDataSource:self];
        [_usersService addDelegate:self];
        
        _logoutGroup = dispatch_group_create();
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

#pragma mark - Methods

- (void)logoutWithCompletion:(dispatch_block_t)completion {
    
    if ([QBSession currentSession].currentUser != nil) {
        
        __weak typeof(self)weakSelf = self;
        dispatch_group_enter(self.logoutGroup);
        [self.authService logOut:^(QBResponse *response) {
            
            __typeof(self) strongSelf = weakSelf;
            [strongSelf.chatService disconnectWithCompletionBlock:nil];
            [strongSelf.chatService free];
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMChatCache instance] deleteAllDialogsWithCompletion:^{
            
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMChatCache instance] deleteAllMessagesWithCompletion:^{
            
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_notify(self.logoutGroup, dispatch_get_main_queue(), ^{
            
            if (completion) {
                
                completion();
            }
        });
    }
    else {
        
        if (completion) {
            
            completion();
        }
    }
}

- (void)logInWithUser:(QBUUser *)user
           completion:(void (^)(BOOL success, NSString *errorMessage))completion {
    
    __weak typeof(self)weakSelf = self;
    [self.authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
        
        if (response.error != nil) {
            
            if (completion != nil) {
                
                completion(NO, response.error.error.localizedDescription);
            }
            
            return;
        }
        
        [weakSelf.chatService connectWithCompletionBlock:^(NSError *error) {
            
            if (completion != nil) {
                
                completion(error == nil, error.localizedDescription);
            }
        }];
    }];
}

- (void)handleErrorResponse:(QBResponse *)response {
    
}

- (BOOL)isAuthorized {
    
    return self.authService.isAuthorized;
}

- (QBUUser *)currentUser {
    
    return [QBSession currentSession].currentUser;
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

#pragma mark - QMChatServiceDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self joinAllGroupDialogsIfNeededWithCompletion:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self joinAllGroupDialogsIfNeededWithCompletion:^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

#pragma mark QMChatServiceCache delegate

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

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
    [QMChatCache.instance deleteMessageWithDialogID:chatDialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteMessageFromMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance deleteMessage:message completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteMessagesFromMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    [QMChatCache.instance deleteMessages:messages completion:nil];
}

- (void)chatService:(QMChatService *)chatService  didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    NSAssert([message.dialogID isEqualToString:dialog.ID], @"must be equal");
    
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
    [QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

#pragma mark QMChatServiceCacheDataSource

- (void)cachedDialogs:(QMCacheCollection)block {
    
    [QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate ascending:YES completion:^(NSArray *dialogs) {
        
        block(dialogs);
    }];
}

- (void)cachedDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion {
    
    [QMChatCache.instance dialogByID:dialogID completion:^(QBChatDialog *cachedDialog) {
        
        completion(cachedDialog);
    }];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    
    [QMChatCache.instance messagesWithDialogId:dialogID sortedBy:CDMessageAttributes.messageID ascending:YES completion:^(NSArray *array) {
        
        block(array);
    }];
}

#pragma mark - QMUsersServiceCacheDataSource

- (void)cachedUsersWithCompletion:(QMCacheCollection)block {
    
    [[QMUsersCache.instance usersSortedBy:@"id" ascending:YES] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                                          withBlock:^id(BFTask *task) {
                                                                              
                                                                              if (block) block(task.result);
                                                                              return nil;
                                                                          }];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray *)users {
    
    [QMUsersCache.instance insertOrUpdateUsers:users];
}

- (void)usersService:(QMUsersService *)usersService didUpdateUsers:(NSArray *)users {
    
    [QMUsersCache.instance insertOrUpdateUsers:users];
}

@end
