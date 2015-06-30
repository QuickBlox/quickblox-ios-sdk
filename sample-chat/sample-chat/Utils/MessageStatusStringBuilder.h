//
//  MessageStatusStringBuilder.h
//  sample-chat
//
//  Created by Andrey Moskvin on 6/30/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageStatusStringBuilder : NSObject

- (NSString *)statusFromMessage:(QBChatMessage *)message;

@end
