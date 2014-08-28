//
//  PushMessage.m
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSMPushMessage.h"

@implementation SSMPushMessage

+ (instancetype)pushMessageWithMessage:(NSString *)message richContentFilesIDs:(NSString *)richContentFilesIDs
{
    return [[SSMPushMessage alloc] initWithMessage:message richContentFilesIDs:richContentFilesIDs];
}

- (instancetype)initWithMessage:(NSString *)message richContentFilesIDs:(NSString *)richContentFileIDs
{
    self = [super init];
    if (self) {
        _message = message;
        _richContentFilesIDs = [richContentFileIDs componentsSeparatedByString:@","];
    }
    return self;
}

@end
