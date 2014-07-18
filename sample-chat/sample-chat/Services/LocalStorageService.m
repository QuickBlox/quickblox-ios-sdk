//
//  LocalStorageService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "LocalStorageService.h"

@implementation LocalStorageService

+ (instancetype)shared
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    
    NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
    for(QBUUser *user in users){
        [__usersAsDictionary setObject:user forKey:@(user.ID)];
    }
    
    _usersAsDictionary = [__usersAsDictionary copy];
}

@end
