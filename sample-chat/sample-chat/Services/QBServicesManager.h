//
//  QBServiceManager.h
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersService.h"

@interface QBServicesManager : NSObject

+ (instancetype)instance;

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL success, NSString *errorMessage))completion;

@property (nonatomic, readonly) QMAuthService* authService;
@property (nonatomic, readonly) QMChatService* chatService;
@property (nonatomic, readonly) UsersService* usersService;

- (QBUUser *)currentUser;

@end
