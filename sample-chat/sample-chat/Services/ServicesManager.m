//
//  QBServiceManager.m
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ServicesManager.h"
#import "_CDMessage.h"
#import <TWMessageBarManager/TWMessageBarManager.h>

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
	}
    
	return self;
}

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
    if ([self.currentDialogID isEqualToString:dialogID]) return;
    
    if (message.senderID == self.currentUser.ID) return;
    
    NSString* dialogName = @"New message";
    
    QBChatDialog* dialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    if (dialog.type != QBChatDialogTypePrivate) {
        dialogName = dialog.name;
    } else {
        QBUUser* user = [self.usersService.usersMemoryStorage userWithID:dialog.recipientID];
        if (user != nil) {
            dialogName = user.login;
        }
    }
    
    [[TWMessageBarManager sharedInstance] hideAll];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:dialogName description:message.text type:TWMessageBarMessageTypeInfo];
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    [super handleErrorResponse:response];
    
    if (![self isAuthorized]) return;
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	if( response.status == 502 ) { // bad gateway, server error
		errorMessage = @"Bad Gateway, please try again";
	}
	else if( response.status == 0 ) { // bad gateway, server error
		errorMessage = @"Connection network error, please try again";
	}
    
    [[TWMessageBarManager sharedInstance] hideAll];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Errors" description:errorMessage type:TWMessageBarMessageTypeError];
}

- (void)downloadLatestUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    /**
     *  Different users are taken depending on environment.
     */
    NSString* environment = nil;
#if DEV
    environment = @"dev";
#endif
    
#if QA
    environment = @"qbqa";
#endif
    
#if RELEASE
    environment = @"release";
#endif
    
    [[self.usersService searchUsersWithTags:@[environment]] continueWithBlock:^id(BFTask *task) {
        //
        if (task.error != nil) {
            if (errorBlock) {
                errorBlock(task.error);
            }
        }
        else {
            NSMutableArray* mutableUsers = [task.result mutableCopy];
            [mutableUsers sortUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
                return [obj1.login compare:obj2.login options:NSNumericSearch];
            }];
            
            if (successBlock != nil) {
                successBlock([mutableUsers copy]);
            }
        }
        
        return nil;
    }];
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastActivityDate forKey:kLastActivityDateKey];
    [defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastActivityDateKey];
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [super chatService:chatService didAddMessageToMemoryStorage:message forDialogID:dialogID];
    
    [self showNotificationForMessage:message inDialogID:dialogID];
}

@end
