//
//  NotificationService.h
//  sample-chat
//
//  Created by Vitaliy Gorbachov on 9/16/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationService : NSObject

/**
 *  Property to track if app was opened from push
 *  if no  - login screen will perform push to dialog controller
 *  if yes - NotificationService will perform dialog controller and then push to chat controller
 */
@property (nonatomic, assign) BOOL appLaunchedByPush;

/**
 *  Open chat page with dialog id from push notification
 *  @param notification userInfo dictionary from didReceiveRemoteNotification
 *  @param completion   completion block
 */
- (void)openChatPageForPushNotification:(NSDictionary *)notification completion:(void(^)(BOOL completed))completionBlock;

@end
