//
//  PushMessage.m
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "PushMessage.h"

@implementation PushMessage

@synthesize message;
@synthesize richContentFilesIDs;

+ (PushMessage *)pushMessageWithMessage:(NSString *)_message richContentFilesIDs:(NSString *)_richContentFilesIDs{
    PushMessage *pushMessage = [[[self class] alloc] init];
    pushMessage.message = _message;
    pushMessage.richContentFilesIDs = [_richContentFilesIDs componentsSeparatedByString:@","];
    return pushMessage;
}


@end
