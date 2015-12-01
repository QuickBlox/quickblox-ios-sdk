//
//  QBServiceManager.h
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationService.h"

/**
 *  Implements logic connected with user's memory/disc storage, error handling, top bar notifications.
 */
@interface ServicesManager : QMServicesManager

/**
 *  Notification service
 */
@property (nonatomic, readonly) NotificationService* notificationService;

/**
 *  Current opened dialog ID.
 */
@property (nonatomic, strong) NSString* currentDialogID;

/**
 *  Last activity date. Needed for updating chat dialogs when go back from tray.
 */
@property (strong, nonatomic) NSDate *lastActivityDate;

/**
 *  Downlaod latest users
 */
- (void)downloadLatestUsersWithSuccessBlock:(void(^)(NSArray *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (NSArray *)filterUsers:(NSArray *)users;

@end
