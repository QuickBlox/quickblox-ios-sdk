//
//  QBServiceManager.h
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersService.h"
#import "QMServicesManager.m"

@interface QBServicesManager : QMServicesManager

@property (nonatomic, readonly) UsersService* usersService;

@property (nonatomic, strong) NSString* currentDialogID;

@end
