//
//  QBChatRoomOccupant.h
//  Сhat
//
//  Created by Igor on 07.05.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatRoomOccupant : NSObject
{
	NSUInteger userID;
    NSString *status;
    NSDictionary *parameters;
}

+ (QBChatRoomOccupant *)occupantWithUserID:(NSUInteger)aUserID parameters:(NSDictionary *)parameters;

- (id)initWithUserID:(NSUInteger)aUserID  parameters:(NSDictionary *)parameters;

@property (readonly) NSUInteger userID;
@property (readonly) NSDictionary *parameters;

@end
