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

@interface QMServicesManager ()

@property (nonatomic, strong) QMAuthService* authService;
@property (nonatomic, strong) QMChatService* chatService;

/**
 *  Logout group for synchronous completion.
 */
@property (nonatomic, strong) dispatch_group_t logoutGroup;

@end

@implementation QMServicesManager

- (instancetype)init {
	self = [super init];
	if (self) {
		[QMChatCache setupDBWithStoreNamed:@"sample-cache"];
        [QMChatCache instance].messagesLimitPerDialog = 10;

		_authService = [[QMAuthService alloc] initWithServiceManager:self];
		_chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        [_chatService addDelegate:self];
        
        [QMUsersCache setupDBWithStoreNamed:@"qb-users-cache"];
        _usersService = [[QMUsersService alloc] initWithServiceManager:self cacheDataSource:self];
        [_usersService addDelegate:self];
        
        _logoutGroup = dispatch_group_create();
	}
	return self;
}

+ (instancetype)instance {
	static QMServicesManager* manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	return manager;
}

- (void)logoutWithCompletion:(dispatch_block_t)completion
{
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
        [[QMChatCache instance] deleteAllDialogs:^{
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMChatCache instance] deleteAllMessages:^{
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_notify(self.logoutGroup, dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)logInWithUser:(QBUUser *)user
		   completion:(void (^)(BOOL success, NSString *errorMessage))completion
{
	[self.authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
		if (response.error != nil) {
			if (completion != nil) {
				completion(NO, response.error.error.localizedDescription);
			}
			return;
		}
		
        __weak typeof(self) weakSelf = self;
        [weakSelf.chatService connectWithCompletionBlock:^(NSError * _Nullable error) {
            //
            __typeof(self) strongSelf = weakSelf;
            
            [strongSelf.chatService loadCachedDialogsWithCompletion:^{
                NSArray* dialogs = [strongSelf.chatService.dialogsMemoryStorage unsortedDialogs];
                for (QBChatDialog* dialog in dialogs) {
                    if (dialog.type != QBChatDialogTypePrivate) {
                        [strongSelf.chatService joinToGroupDialog:dialog completion:^(NSError * _Nullable error) {
                            //
                            if (error != nil) {
                                NSLog(@"Join error: %@", error.localizedDescription);
                            }
                        }];
                    }
                }
                
                if (completion != nil) {
                    completion(error == nil, error.localizedDescription);
                }
                
            }];
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

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
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

- (void)cachedUsers:(QMCacheCollection)block {
    [[QMUsersCache.instance usersSortedBy:@"id" ascending:YES] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                                          withBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
                                                                              if (block) block(task.result);
                                                                              return nil;
                                                                          }];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)users
{
    [QMUsersCache.instance insertOrUpdateUsers:users];
}


@end
