//
//  QBServiceManager.m
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "QBServicesManager.h"
#import "StorageManager.h"

@interface QBServicesManager () <QMServiceManagerProtocol, QMChatServiceCacheDelegate>

@property (nonatomic, strong) QMAuthService* authService;
@property (nonatomic, strong) QMChatService* chatService;
@property (nonatomic, strong) UsersService* usersService;
@end

@implementation QBServicesManager

- (instancetype)init {
	self = [super init];
	if (self) {
		[QMChatCache setupDBWithStoreNamed:@"sample-cache"];
		_authService = [[QMAuthService alloc] initWithServiceManager:self];
		_chatService = [[QMChatService alloc] initWithServiceManager:self cacheDelegate:self];
		_usersService = [[UsersService alloc] init];
	}
	return self;
}

+ (instancetype)instance {
	static QBServicesManager* manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[QBServicesManager alloc] init];
	});
	return manager;
}

- (void)logInWithUser:(QBUUser *)user
		   completion:(void (^)(BOOL success, NSString *errorMessage))completion {
	
	[[QBServicesManager instance].authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
		
		if( response.error != nil ){
			if( completion != nil ) {
				completion(NO, response.error.error.localizedDescription);
			}
			return;
		}
		if( QBServicesManager.instance.currentUser != nil ){
			[QBServicesManager.instance.chatService logoutChat];
			[StorageManager.instance reset];
		}
		
		[QBServicesManager.instance.chatService logIn:^(NSError *error) {
			if( completion != nil ) {
				completion(error == nil, error.localizedDescription);
			}
		}];
	}];
}


- (void)handleErrorResponse:(QBResponse *)response {
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
													message:errorMessage
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles: nil];
	[alert show];
}

- (BOOL)isAutorized {
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

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService  didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
	NSAssert(message.dialogID == dialog.ID, @"must be equal");
	
	[QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
	[QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

- (void)cachedDialogs:(QMCacheCollection)block {
	[QMChatCache.instance dialogsSortedBy:@"lastMessageDate" ascending:YES completion:^(NSArray *dialogs) {
		block(dialogs);
	}];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
	[QMChatCache.instance messagesWithDialogId:dialogID sortedBy:@"ID" ascending:YES completion:^(NSArray *array) {
		block(array);
	}];
}

@end
