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
        return [NSString stringWithFormat:@"Read: %@", [message.readIDs componentsJoinedByString:@", "]];
    } else {
        return @"Sent";
    }
}

@end
