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
static const NSString *const kTestUsersTableKey = @"test_users";
static const NSString *const kUserFullNameKey = @"fullname";
static const NSString *const kUserLoginKey = @"login";
static const NSString *const kUserPasswordKey = @"password";


/**
 *  QBServicesManager
 */
static const NSString *const kChatCacheNameKey = @"sample-cache";


/**
 *  LoginTableViewController
 */
static const NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

/**
 *  DialogsViewController
 */
static const NSUInteger kDialogsPageLimit = 10;

#endif
