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
#import <MPGNotification/MPGNotification.h>
@interface ServicesManager ()

@property (nonatomic, strong) QMContactListService* contactListService;
@property (nonatomic, strong) MPGNotification *notification;
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
        _notification = [MPGNotification new];
        _notification.duration = 2.0;
        _notification.swipeToDismissEnabled = YES;
        [_notification setAnimationType:MPGNotificationAnimationTypeLinear];
        
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
    UIImage *iconImage = [UIImage imageNamed:@"icon-info"];
    UIColor * backgroundColor = [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];

    [self showNotificationWithTitle:title
                           subtitle:subtitle
                              color:backgroundColor
                          iconImage:iconImage];
    
    NSString * title2  = NSLocalizedString(@"SA_STR_ERROR", nil);
    NSString * subtitle2 = @"vdvdvd";
    UIImage *iconImage2 = [UIImage imageNamed:@"icon-error"];
    UIColor *backgroundColor2 = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0];
    
    [self showNotificationWithTitle:title2
                           subtitle:subtitle2
                              color:backgroundColor2
                          iconImage:iconImage2];

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
    UIImage *iconImage = [UIImage imageNamed:@"icon-error"];
    UIColor *backgroundColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0];

    [self showNotificationWithTitle:title
                           subtitle:subtitle
                              color:backgroundColor
                          iconImage:iconImage];
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

- (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage {
    
    [self.notification dismissWithAnimation:NO];
    self.notification =  [MPGNotification new];
    self.notification.duration = 2.0;
    self.notification.swipeToDismissEnabled = YES;
    [self.notification setAnimationType:MPGNotificationAnimationTypeLinear];
    self.notification.title = title;
    self.notification.subtitle = subtitle;
    self.notification.iconImage = iconImage;
    self.notification.backgroundColor = color;
    [self.notification show];

}

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
    
    [self showNotificationForMessage:message inDialogID:dialogID];
}

@end
