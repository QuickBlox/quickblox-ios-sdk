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
			if (user) {
				[readLogins addObject:user.login];
			}
			else {
				NSString *unkownUserLogin = [@"@%@" stringByAppendingString:[readID stringValue]];
				[readLogins addObject:unkownUserLogin];
			}
        }
        
        if (readLogins.count > 0) {
            if (message.attachments.count > 0) {
                [statusString appendFormat:@"%@: %@", NSLocalizedString(@"SA_STR_SEEN_STATUS", nil), [readLogins componentsJoinedByString:@", "]];
            } else {
                [statusString appendFormat:@"%@: %@", NSLocalizedString(@"SA_STR_READ_STATUS", nil), [readLogins componentsJoinedByString:@", "]];
            }
        }
        
        NSMutableArray* deliveredLogins = [NSMutableArray array];
        for (NSNumber* deliveredID in deliveredIDs) {
            QBUUser *user = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[deliveredID unsignedIntegerValue]];
			if (user) {
				[deliveredLogins addObject:user.login];
			}
			else {
				NSString *unkownUserLogin = [@"@%@" stringByAppendingString:[deliveredID stringValue]];
				[deliveredLogins addObject:unkownUserLogin];
			}
			
        }
        
        if (deliveredLogins.count > 0) {
            if (readLogins.count > 0) [statusString appendString:@"\n"];
            [statusString appendFormat:@"%@: %@", NSLocalizedString(@"SA_STR_DELIVERED_STATUS", nil), [deliveredLogins componentsJoinedByString:@", "]];
        }
        
        return [statusString copy];
    }
    
    QMMessageStatus status = [[ServicesManager instance].chatService.deferredQueueManager statusForMessage:message];
    NSString * messageStatus;
    switch (status) {
        case QMMessageStatusSent: {
            messageStatus = @"SA_STR_SENT_STATUS";
            break;
        }
        case QMMessageStatusSending: {
            messageStatus = @"Sending";
            break;
        }
        case QMMessageStatusNotSent: {
            messageStatus = @"Not sent";
            break;
        }
    }
    return NSLocalizedString(messageStatus, nil);
}

@end
