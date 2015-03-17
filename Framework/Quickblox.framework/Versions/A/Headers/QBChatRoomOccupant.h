//
//  QBChatRoomOccupant.h
//  Сhat
//
//  Created by Igor on 07.05.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatRoomOccupant : NSObject <NSCoding>
{
	NSString *nickname;
    NSDictionary *parameters;
}

+ (QBChatRoomOccupant *)occupantWithUserNickname:(NSString *)aNickname parameters:(NSDictionary *)parameters;

- (id)initWithUserNickname:(NSString *)aNickname  parameters:(NSDictionary *)parameters;

@property (readonly) NSString *nickname;
@property (readonly) NSDictionary *parameters;

@end
