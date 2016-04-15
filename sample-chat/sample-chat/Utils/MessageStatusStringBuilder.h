//
//  MessageStatusStringBuilder.h
//  sample-chat
//
//  Created by Andrey Moskvin on 6/30/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Responsible for building string for message status.
 */
@interface MessageStatusStringBuilder : NSObject

/**
 *  Builds a string
	Read: login1, login2, login3
	Delivered: login1, login3, @12345
	
	If there is no user in usersMemoryStorage, then ID will be used instead of login
 *
 *  @param message QBChatMessage instance
 *
 *  @return status string
 */
- (NSString *)statusFromMessage:(QBChatMessage *)message;

@end
