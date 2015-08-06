//
//  MessageStatusStringBuilder.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/30/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "MessageStatusStringBuilder.h"
#import "ServicesManager.h"

@implementation MessageStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message
{
    if (message.readIDs.count > 0) {
        NSMutableArray* readIDs = [message.readIDs mutableCopy];
        [readIDs removeObject:@([QBSession currentSession].currentUser.ID)];
        
        NSMutableArray* readLogins = [NSMutableArray array];
        for (NSNumber* readID in readIDs) {
            QBUUser* user = [ServicesManager.instance.usersService.contactListService.usersMemoryStorage userWithID:[readID unsignedIntegerValue]];
            NSAssert(user != nil, @"User must not be nil!");
            [readLogins addObject:user.login];
        }
        
        if (readLogins.count > 0) {
            return [NSString stringWithFormat:@"Read: %@", [readLogins componentsJoinedByString:@", "]];
        }
    }
    return @"Sent";
}

@end
