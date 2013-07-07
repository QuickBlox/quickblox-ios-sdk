//
//  QBChatRoom.h
//  Сhat
//
//  Created by Alexey on 11.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatRoom structure. Represents chat room entity
 */

@interface QBChatRoom : NSObject <NSCoding, NSCopying>{
}

/**
 Room name
 */
@property (readonly) NSString *name;

/**
 Room JID
 */
@property (readonly) NSString *JID;

/**
 Is current user joined this room
 */
@property (readonly) BOOL isJoined;

/**
 Init QBChatRoom instance with name
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(&),('),(/),(:),(<),(>),(@) (double quote, ampersand, single quote, forward slash, colon, less than, greater than, at-sign) characters - they will be removed.
 
 @return QBChatRoom instance
 */
- (id)initWithRoomName:(NSString *)roomName;

/**
 Add users to current room. Array users contains users' ids
 */
- (void)addUsers:(NSArray *)users;

/**
 Delete users from current room. Array users contains users' ids
 */
- (void)deleteUsers:(NSArray *)users;

/**
 Send message to current room
 */
- (void)sendMessage:(QBChatMessage *)message;

/**
 Join current room
 */
- (void)joinRoom;

/**
 Leave current room
 */
- (void)leaveRoom;

/**
 Request all room's users, users who can join room
 */
- (void)requestUsers;

/**
 Request room's online users
 */
- (void)requestOnlineUsers;

/**
 Request room information
 */
- (void)requestInformation;

@end
