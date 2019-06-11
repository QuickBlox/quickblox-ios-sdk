//
//  Constants.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#ifndef sample_chat_Constants_h
#define sample_chat_Constants_h

/**
 *  UsersDataSource
 */
static NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";

/**
 *  ServicesManager
 */
static NSString *const kChatCacheNameKey = @"sample-cache";
static NSString *const kContactListCacheNameKey = @"sample-cache-contacts";
static NSString *const kLastActivityDateKey = @"last_activity_date";

/**
 *  LoginTableViewController
 */
static NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

/**
 *  DialogsViewController
 */
static const NSUInteger kDialogsPageLimit = 10;

static NSString *const kGoToEditDialogSegueIdentifier = @"goToEditDialog";

/**
 *  DialogInfoTableViewController
 */
static NSString *const kGoToAddOccupantsSegueIdentifier = @"goToAddOccupants";

/**
 *  EditDialogTableViewController
 */
static NSString *const kGoToChatSegueIdentifier = @"goToChat";

/**
 * Dialog keys
 */
static NSString *const kPushNotificationDialogIdentifierKey = @"dialog_id";
static NSString *const kPushNotificationDialogMessageKey = @"message";

#endif
