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
NSString *const kTestUsersTableKey = @"test_users";
NSString *const kUserFullNameKey = @"fullname";
NSString *const kUserLoginKey = @"login";
NSString *const kUserPasswordKey = @"password";


/**
 *  QBServicesManager
 */
NSString *const kChatCacheNameKey = @"sample-cache";


/**
 *  LoginTableViewController
 */
NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

/**
 *  DialogsViewController
 */
const NSUInteger kDialogsPageLimit = 10;

#endif
