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
        NSMutableString* statusString = [NSMutableString string];
        NSMutableArray* readIDs = [message.readIDs mutableCopy];
        [readIDs removeObject:@([QBSession currentSession].currentUser.ID)];
        
        NSMutableArray* readLogins = [NSMutableArray array];
        for (NSNumber* readID in readIDs) {
            QBUUser* user = [ServicesManager.instance.usersService.contactListService.usersMemoryStorage userWithID:[readID unsignedIntegerValue]];
            NSAssert(user != nil, @"User must not be nil!");
            [readLogins addObject:user.login];
        }
        
        if (readLogins.count > 0) {
            [statusString appendFormat:@"Read: %@", [readLogins componentsJoinedByString:@", "]];
        }
        
        NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
        [deliveredIDs removeObject:@([QBSession currentSession].currentUser.ID)];
        
        NSMutableArray* deliveredLogins = [NSMutableArray array];
        for (NSNumber* deliveredID in deliveredIDs) {
            QBUUser* user = [ServicesManager.instance.usersService.contactListService.usersMemoryStorage userWithID:[deliveredID unsignedIntegerValue]];
            NSAssert(user != nil, @"User must not be nil!");
            [deliveredLogins addObject:user.login];
        }
        
        if (deliveredLogins.count > 0) {
            [statusString appendFormat:@"\nDelivered: %@", [deliveredLogins componentsJoinedByString:@", "]];
        }
        
        return [statusString copy];
    }
    return @"Sent";
}

@end
