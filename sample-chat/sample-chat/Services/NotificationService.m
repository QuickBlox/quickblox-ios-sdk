//
//  NotificationService.m
//  sample-chat
//
//  Created by Vitaliy Gorbachov on 9/16/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "NotificationService.h"
#import "ServicesManager.h"
#import "ChatViewController.h"
#import "DialogsViewController.h"

@implementation NotificationService

- (void)openChatPageForPushNotification:(NSDictionary *)notification completion:(void(^)(BOOL completed))completionBlock
{
    NSString *dialogID = notification[kDialogIdentifierKey];
    
    if (dialogID == nil || ServicesManager.instance.currentUser == nil) {
        
        if (completionBlock)
            completionBlock(NO);
        
        return;
    }
    
    QBChatDialog *dialog = [ServicesManager.instance.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    if (dialog == nil) {
        __weak typeof(self)weakSelf = self;
        
        [ServicesManager.instance.chatService fetchDialogWithID:dialogID completion:^(QBChatDialog *chatDialog) {
            if (chatDialog != nil) {
                [weakSelf openChatPageForPushNotification:notification completion:completionBlock];
            }
        }];
        
        return;
        
    } else {
        
        [self openChatControllerForDialogWithID:dialogID];
        self.appLaunchedByPush = YES;
        if (completionBlock) completionBlock(YES);
    }
}

- (void)openChatControllerForDialogWithID:(NSString *)dialogID
{
    NSString *dialogWithIDWasEntered = [ServicesManager instance].currentDialogID;
    if ([dialogWithIDWasEntered isEqualToString:dialogID]) {
        return;
    }
    
    ChatViewController *chatController = (ChatViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.dialog = [ServicesManager.instance.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootController = window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)rootController;
    
    if (dialogWithIDWasEntered != nil) {
        // some chat already opened, return to dialogs view controller first
        [navigationController popViewControllerAnimated:NO];
    }
    
    // check if Dialogs view controller exists in UINavigationController stack
    // if not - create it
    NSUInteger numberOfViewControllers = navigationController.viewControllers.count;
    if (numberOfViewControllers < 2) {
        DialogsViewController *dialogsController = (DialogsViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DialogsViewController"];
        [navigationController pushViewController:dialogsController animated:NO];
    }
    
    [navigationController pushViewController:chatController animated:NO];
}

@end
