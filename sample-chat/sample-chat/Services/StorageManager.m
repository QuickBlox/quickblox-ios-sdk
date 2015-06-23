//
//  StorageManager.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "StorageManager.h"

@implementation StorageManager

+ (instancetype)instance {
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (QBUUser *)userByID:(NSUInteger)identifier
{
    __block QBUUser* userToFind = nil;
    [self.users enumerateObjectsUsingBlock:^(QBUUser* obj, NSUInteger idx, BOOL *stop) {
        if (obj.ID == identifier) {
            userToFind = obj;
            *stop = YES;
        }
    }];
    
    return userToFind;
}
@end
