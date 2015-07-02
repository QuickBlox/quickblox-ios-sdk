//
//  MessageStatusStringBuilder.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/30/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "MessageStatusStringBuilder.h"

@implementation MessageStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message
{
    if (message.readIDs.count > 0) {
        NSMutableArray* readIDs = [message.readIDs mutableCopy];
        [readIDs removeObject:@([QBSession currentSession].currentUser.ID)];
        if (readIDs.count > 0) {
            return [NSString stringWithFormat:@"Read: %@", [readIDs componentsJoinedByString:@", "]];
        }
    }
    return @"Sent";
}

@end
