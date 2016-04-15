//
//  NotificationService.m
//  sample-chat
//
//  Created by Vitaliy Gorbachov on 9/18/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "NotificationService.h"
#import "ServicesManager.h"

@implementation NotificationService

- (void)handlePushNotificationWithDelegate:(id<NotificationServiceDelegate>)delegate {
    if (self.pushDialogID == nil) return;
    
    self.delegate = delegate;
    
    __weak __typeof(self)weakSelf = self;
    [ServicesManager.instance.chatService fetchDialogWithID:self.pushDialogID completion:^(QBChatDialog *chatDialog) {
        //
        __typeof(weakSelf)strongSelf = weakSelf;
        if (chatDialog != nil) {
            strongSelf.pushDialogID = nil;
			
            if ([strongSelf.delegate respondsToSelector:@selector(notificationServiceDidSucceedFetchingDialog:)]) {
                [strongSelf.delegate notificationServiceDidSucceedFetchingDialog:chatDialog];
            }
        }
        else {
			
            if ([strongSelf.delegate respondsToSelector:@selector(notificationServiceDidStartLoadingDialogFromServer)]) {
                [strongSelf.delegate notificationServiceDidStartLoadingDialogFromServer];
            }
            [ServicesManager.instance.chatService loadDialogWithID:strongSelf.pushDialogID completion:^(QBChatDialog *loadedDialog) {
				
                strongSelf.pushDialogID = nil;
                if ([strongSelf.delegate respondsToSelector:@selector(notificationServiceDidFinishLoadingDialogFromServer)]) {
                    [strongSelf.delegate notificationServiceDidFinishLoadingDialogFromServer];
                }
                if (loadedDialog != nil) {
					
                    if ([strongSelf.delegate respondsToSelector:@selector(notificationServiceDidSucceedFetchingDialog:)]) {
                        [strongSelf.delegate notificationServiceDidSucceedFetchingDialog:loadedDialog];
                    }
                }
                else {
					
                    if ([strongSelf.delegate respondsToSelector:@selector(notificationServiceDidFailFetchingDialog)]) {
                        [strongSelf.delegate notificationServiceDidFailFetchingDialog];
                    }
                }
            }];
        }
    }];
}

@end
