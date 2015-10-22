//
//  QBServiceManager.h
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersService.h"
#import "NotificationService.h"

#define qbUsersMemoryStorage ServicesManager.instance.usersService.contactListService.usersMemoryStorage
/**
 *  Implements logic connected with user's memory/disc storage, error handling, top bar notifications.
 */
@interface ServicesManager : QMServicesManager <QMContactListServiceCacheDataSource>

/**
 *  User's service.
 */
@property (nonatomic, readonly) UsersService* usersService;

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
 *  Joining all group dialogs
 */
- (void)joinAllGroupDialogs;

@end
