//
//  NotificationService.h
//  sample-chat
//
//  Created by Vitaliy Gorbachov on 9/18/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NotificationServiceDelegate <NSObject>
@required

/**
 *  Is called when dialog fetching is complete and ready to return requested dialog
 *
 *  @param chatDialog QBChatDialog instance. Successfully fetched dialog
 */
- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog;

@optional

/**
 *  Is called when dialog was not found nor in memory storage nor in cache
 *  and NotificationService started requesting dialog from server
 */
- (void)notificationServiceDidStartLoadingDialogFromServer;

/**
 *  Is called when dialog request from server was completed
 */
- (void)notificationServiceDidFinishLoadingDialogFromServer;

/**
 *  Is called when dialog was not found in both memory storage and cache
 *  and server request return nil
 */
- (void)notificationServiceDidFailFetchingDialog;
@end

@interface NotificationService : NSObject

/**
 *  NotificationServiceDelegate protocol delegate
 */
@property (nonatomic, weak) id <NotificationServiceDelegate> delegate;

/**
 *  Dialog id that was recieved from push
 */
@property (nonatomic, strong) NSString *pushDialogID;

/*
 *  Handle push notification method
 */
- (void)handlePushNotificationWithDelegate:(id<NotificationServiceDelegate>)delegate;

@end
