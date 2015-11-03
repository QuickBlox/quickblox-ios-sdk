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
    NSNumber* currentUserID = @([QBSession currentSession].currentUser.ID);
    
    NSMutableArray* readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:currentUserID];
    
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:currentUserID];
    
    [deliveredIDs removeObjectsInArray:readIDs];

    if (readIDs.count > 0 || deliveredIDs.count > 0) {
        NSMutableString* statusString = [NSMutableString string];
        
        NSMutableArray* readLogins = [NSMutableArray array];
        for (NSNumber* readID in readIDs) {
            QBUUser* user = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[readID unsignedIntegerValue]];
            NSAssert(user != nil, @"User must not be nil!");
            [readLogins addObject:user.login];
        }
        
        if (readLogins.count > 0) {
            if (message.attachments.count > 0) {
                [statusString appendFormat:@"Seen: %@", [readLogins componentsJoinedByString:@", "]];
            } else {
                [statusString appendFormat:@"Read: %@", [readLogins componentsJoinedByString:@", "]];
            }
        }
        
        NSMutableArray* deliveredLogins = [NSMutableArray array];
        for (NSNumber* deliveredID in deliveredIDs) {
            QBUUser* user = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[deliveredID unsignedIntegerValue]];
            NSAssert(user != nil, @"User must not be nil!");
            [deliveredLogins addObject:user.login];
        }
        
        if (deliveredLogins.count > 0) {
            if (readLogins.count > 0) [statusString appendString:@"\n"];
            [statusString appendFormat:@"Delivered: %@", [deliveredLogins componentsJoinedByString:@", "]];
        }
        
        return [statusString copy];
    }
    return @"Sent";
}

@end
