//
//  QMServiceManager.h
//  QMServices
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServices.h"

/**
 *  Base manager that handles authentication and chat functionality.
 */
@interface QMServicesManager : NSObject
<
QMServiceManagerProtocol,
QMChatServiceCacheDataSource,
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMUsersServiceCacheDataSource,
QMUsersServiceDelegate
>

+ (instancetype)instance;

/**
 *  Login to Quickblox REST and chat, group dialog join.
 *
 *  @param user       QBUUser for login.
 *  @param completion Completion block with a result.
 */
- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL success, NSString *errorMessage))completion;

/**
 *  Logouts from Quickblox REST and chat, clears dialogs and messages.
 *
 *  @param completion Completion block with a result.
 */
- (void)logoutWithCompletion:(dispatch_block_t)completion;

/**
 *  REST authentication service.
 */
@property (nonatomic, readonly) QMAuthService* authService;

/**
 *  Chat service.
 */
@property (nonatomic, readonly) QMChatService* chatService;

/**
 *  Users service.
 */
@property (strong, nonatomic, readonly) QMUsersService* usersService;

@end
