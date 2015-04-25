//
//  QBChatRoom.h
//  Сhat
//
//  Created by Alexey on 11.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatMessage;

/**
 QBChatRoom structure. Represents chat room entity
 */

@interface QBChatRoom : NSObject <NSCoding, NSCopying>
/**
 Room name
 */
@property (strong, nonatomic, readonly) NSString *name;

/**
 Room JID
 */
@property (strong, nonatomic, readonly) NSString *JID;

/**
 Is current user joined this room
 */
@property (assign, nonatomic, readonly) BOOL isJoined;

/**
 Init QBChatRoom instance with name
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 As user room nickname we will use user ID
 
 @warning *Deprecated in QB iOS SDK 1.8.6:* Use method with JID instead
 
 @param roomName Room name
 @return QBChatRoom instance
 */
- (id)initWithRoomName:(NSString *)roomName;

/**
 Init QBChatRoom instance with name & user nickname
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 
 @warning *Deprecated in QB iOS SDK 1.8.6:* Use method with JID instead
 
 @param roomName Room name
 @param nickname User nickname wich will be used in room
 @return QBChatRoom instance
 */
- (id)initWithRoomName:(NSString *)roomName nickname:(NSString *)nickname;

/**
 Init QBChatRoom instance with JID
 
 @param roomJID Room JID
 @return QBChatRoom instance
 */
- (id)initWithRoomJID:(NSString *)roomJID;

/**
 Init QBChatRoom instance with JID & user nickname
 
 @param roomJID Room JID
 @param nickname User nickname wich will be used in room
 @return QBChatRoom instance
 */
- (id)initWithRoomJID:(NSString *)roomJID nickname:(NSString *)nickname;

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
 Send message to current room, without join it
 */
- (void)sendMessageWithoutJoin:(QBChatMessage *)message;

/**
 Join current room
 */
- (void)joinRoom;

/**
 Join current room
 
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 */
- (void)joinRoomWithHistoryAttribute:(NSDictionary *)historyAttribute;

/**
 Leave current room
 */
- (void)leaveRoom;

/**
 Request all room's users, users who can join room
 */
- (void)requestUsers;

/**
 Request room's users with affiliation
 */
- (void)requestUsersWithAffiliation:(NSString *)affiliation;

/**
 Request room's online users
 */
- (void)requestOnlineUsers;

/**
 Request room information
 */
- (void)requestInformation;

@end
