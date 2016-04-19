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
 *  Notification service.
 */
@property (nonatomic, readonly) NotificationService* notificationService;

/**
 *  Current opened dialog ID.
 */
@property (nonatomic, strong) NSString* currentDialogID;

/**
 *  Last activity date. Needed for updating chat dialogs when going back from tray.
 */
@property (strong, nonatomic) NSDate *lastActivityDate;

/**
 *  Download users accordingly to self.currentEnvironment
 */
- (void)downloadCurrentEnvironmentUsersWithSuccessBlock:(void(^)(NSArray QB_GENERIC(QBUUser *) *latestUsers))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

/**
 *  Sorted array of users.
 *
 *  @return sorted array of users from memory storage
 */
- (NSArray QB_GENERIC(QBUUser *) *)sortedUsers;

@end
