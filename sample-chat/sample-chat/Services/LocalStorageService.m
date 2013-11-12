//
//  LocalStorageService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "LocalStorageService.h"

@implementation LocalStorageService{
    NSMutableDictionary *messagesHistory;
}

+ (instancetype)shared
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (id)init
{
    self = [super init];
    if(self){
        messagesHistory = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)saveMessageToHistory:(QBChatMessage *)message withUserID:(NSUInteger)userID
{
    NSMutableArray *messages = [messagesHistory objectForKey:@(userID)];
    if(messages == nil){
        messages = [NSMutableArray array];
        [messagesHistory setObject:messages forKey:@(userID)];
    }
    [messages addObject:message];
}

- (NSMutableArray *)messageHistoryWithUserID:(NSUInteger)userID
{
    NSMutableArray *messages = [messagesHistory objectForKey:@(userID)];
    if(messages == nil){
        messages = [NSMutableArray array];
        [messagesHistory setObject:messages forKey:@(userID)];
    }
    return messages;
}


@end
