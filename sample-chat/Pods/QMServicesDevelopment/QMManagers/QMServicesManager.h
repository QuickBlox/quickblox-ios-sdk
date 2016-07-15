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

/**
 *  REST authentication service.
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMAuthService* authService;

/**
 *  Chat service.
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMChatService* chatService;

/**
 *  Users service.
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMUsersService* usersService;

+ (QB_NONNULL instancetype)instance;

/**
 *  Determines whether extended services logging is enabled.
 *
 *  @param enable whether logs should be enabled or not
 *
 *  @discussion By default logs are enabled.
 *
 *  @note If you don't want logs in production environment you should disable them within this flag.
 */
+ (void)enableLogging:(BOOL)flag;

/**
 *  Login to Quickblox REST and chat, group dialog join.
 *
 *  @param user       QBUUser for login.
 *  @param completion Completion block with a result.
 */
- (void)logInWithUser:(QB_NONNULL QBUUser *)user completion:(void(^QB_NULLABLE_S)(BOOL success, NSString * QB_NULLABLE_S errorMessage))completion;

/**
 *  Logouts from Quickblox REST and chat, clears dialogs and messages.
 *
 *  @param completion Completion block with a result.
 */
- (void)logoutWithCompletion:(QB_NULLABLE dispatch_block_t)completion;

@end
