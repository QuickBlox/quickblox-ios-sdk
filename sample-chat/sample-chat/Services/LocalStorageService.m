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

- (id)init{
    self = [super init];
    if(self){
        self.messages = [NSMutableDictionary dictionary];
    }
    return self;
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

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId{
    NSMutableArray *messages = [self.messages objectForKey:dialogId];
    if(messages == nil){
        messages = [NSMutableArray array];
        [self.messages setObject:messages forKey:dialogId];
    }
    
    return messages;
}

- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObjectsFromArray:messages];
    }else{
        [self.messages setObject:messages forKey:dialogId];
    }
}

- (void)addMessage:(QBChatAbstractMessage *)message forDialogId:(NSString *)dialogId{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObject:message];
    }else{
        NSMutableArray *messages = [NSMutableArray array];
        [messages addObject:message];
        [self.messages setObject:messages forKey:dialogId];
    }
}

@end
