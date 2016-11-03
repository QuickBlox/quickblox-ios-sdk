//
//  QMServiceManager.h
//  QMServices
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServices.h"

NS_ASSUME_NONNULL_BEGIN

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
@property (strong, nonatomic, readonly) QMAuthService *authService;

/**
 *  Chat service.
 */
@property (strong, nonatomic, readonly) QMChatService *chatService;

/**
 *  Users service.
 */
@property (strong, nonatomic, readonly) QMUsersService *usersService;

+ (instancetype)instance;

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
- (void)logInWithUser:(QBUUser *)user completion:(nullable void(^)(BOOL success, NSString * _Nullable errorMessage))completion;

/**
 *  Logouts from Quickblox REST and chat, clears dialogs and messages.
 *
 *  @param completion Completion block with a result.
 */
- (void)logoutWithCompletion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
