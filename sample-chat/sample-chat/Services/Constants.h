//
//  Constants.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/29/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#ifndef sample_chat_Constants_h
#define sample_chat_Constants_h


/**
 *  UsersService
 */
static NSString *const kTestUsersTableKey = @"test_users";
static NSString *const kUserFullNameKey = @"fullname";
static NSString *const kUserLoginKey = @"login";
static NSString *const kUserPasswordKey = @"password";

/**
 *  UsersDataSource
 */
static NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";

/**
 *  QBServicesManager
 */
static NSString *const kChatCacheNameKey = @"sample-cache";


/**
 *  LoginTableViewController
 */
static NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

/**
 *  DialogsViewController
 */
static const NSUInteger kDialogsPageLimit = 10;

#endif
