//
//  QBServiceManager.m
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ServicesManager.h"
#import "_CDMessage.h"
#import "QMMessageNotificationManager.h"
@interface ServicesManager ()

@property (nonatomic, strong) QMContactListService* contactListService;

@end

@implementation ServicesManager

- (NSArray *)unsortedUsers
{
    return [self.usersService.usersMemoryStorage unsortedUsers];
}

- (instancetype)init {
	self = [super init];
    
	if (self) {
        _notificationService = [[NotificationService alloc] init];
        [QMMessageNotificationManager oneByOneModeSetEnabled:NO];
    }
    
	return self;
}

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
    if ([self.currentDialogID isEqualToString:dialogID]) return;
    
    if (message.senderID == self.currentUser.ID) return;
    
    NSString* dialogName = NSLocalizedString(@"SA_STR_NEW_MESSAGE", nil);
    
    QBChatDialog* dialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    if (dialog.type != QBChatDialogTypePrivate) {
        dialogName = dialog.name;
    } else {
        QBUUser* user = [self.usersService.usersMemoryStorage userWithID:dialog.recipientID];
        if (user != nil) {
            dialogName = user.login;
        }
    }

    NSString * title = dialogName;
    NSString *subtitle = message.text;

    [QMMessageNotificationManager showNotificationWithTitle:title
                                                   subtitle:subtitle
                                                       type:QMMessageNotificationTypeInfo];

}

- (void)handleErrorResponse:(QBResponse *)response {
    
    [super handleErrorResponse:response];
    
	if (![self isAuthorized]){
		return;
	}
	
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	if( response.status == 502 ) { // bad gateway, server error
		errorMessage = NSLocalizedString(@"SA_STR_BAD_GATEWAY", nil);
	}
	else if( response.status == 0 ) { // bad gateway, server error
		errorMessage = NSLocalizedString(@"SA_STR_NETWORK_ERROR", nil);
	}
    
    NSString * title  = NSLocalizedString(@"SA_STR_ERROR", nil);
    NSString * subtitle = errorMessage;

    [QMMessageNotificationManager showNotificationWithTitle:title
                                                   subtitle:subtitle
                                                       type:QMMessageNotificationTypeWarning];
}

- (void)downloadCurrentEnvironmentUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak __typeof(self)weakSelf = self;
    [[self.usersService searchUsersWithTags:@[[self currentEnvironment]]] continueWithBlock:^id(BFTask *task) {
        //
        if (task.error != nil) {
            if (errorBlock) {
                errorBlock(task.error);
            }
        }
        else {
            
            if (successBlock != nil) {
                successBlock([weakSelf sortedUsers]);
            }
        }
        
        return nil;
    }];
}

- (NSArray *)sortedUsers {
    
    NSArray *users = [self.usersService.usersMemoryStorage unsortedUsers];
    
    NSMutableArray *mutableUsers = [users mutableCopy];
    [mutableUsers sortUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
        return [obj1.login compare:obj2.login options:NSNumericSearch];
    }];
    
    return [mutableUsers copy];
}

#pragma mark - Helpers

- (NSString *)currentEnvironment {
    NSString* environment = nil;
#if DEV
    environment = @"dev";
#endif
    
#if QA
    environment = @"qbqa";
#endif
    
    return environment;
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastActivityDate forKey:kLastActivityDateKey];
    [defaults synchronize];
}

- (NSDate *)lastActivityDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastActivityDateKey];
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [super chatService:chatService didAddMessageToMemoryStorage:message forDialogID:dialogID];
    
    if (self.authService.isAuthorized) {
        [self showNotificationForMessage:message inDialogID:dialogID];
    }
}


@end
