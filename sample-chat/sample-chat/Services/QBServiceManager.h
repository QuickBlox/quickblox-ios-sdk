//
//  QBServiceManager.h
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersService.h"

@interface QBServiceManager : NSObject

+ (instancetype)instance;

@property (nonatomic, readonly) QMAuthService* authService;
@property (nonatomic, readonly) QMChatService* chatService;
@property (nonatomic, readonly) UsersService* usersService;

- (QBUUser *)currentUser;

@end
