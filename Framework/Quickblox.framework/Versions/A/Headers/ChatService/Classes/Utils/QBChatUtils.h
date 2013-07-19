//
//  QBChatUtils.h
//  Quickblox
//
//  Created by IgorKh on 4/4/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define xmppRoomField @"xmppRoom"

@interface QBChatUtils : NSObject

// QBUser <-> JID
+ (NSString *)JIDFromUserID:(NSUInteger)userID;
+ (NSUInteger)userIDFromJID:(NSString *)jid;

// QBChatMessage <-> xmppMessage
+ (QBChatMessage *)messageFromXMPPMessage:(id)message roomNick:(NSString *)roomNick;
+ (id)xmppMessageFromQBChatMessage:(QBChatMessage *)message;

// Rooms utils
+ (NSString *)roomNameFromJID:(NSString *)roomJID;
+ (NSString *)roomJIDFromName:(NSString *)roomName;

+ (QBChatRoom *)roomFromJID:(NSString *)roomJID name:(NSString *)roomName andAddDelegate:(BOOL)addDelegate;

/**
 Validate room name.
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(&),('),(/),(:),(<),(>),(@) (double quote, ampersand, single quote, forward slash, colon, less than, greater than, at-sign) characters - they will be removed.
 
 @param roomName Name of room
 @return Valid name of room
 */
+ (NSString *)roomNameToValidRoomName:(NSString *)roomName;

// Presense utils
+ (NSString *)parsePresenseShowToString:(enum QBPresenseShow)show;
+ (enum QBPresenseShow)parsePresenseShowToEnum:(NSString *)show;

// Image rotation
+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;


// Extract custom params from XMPPMessage
+ (NSMutableDictionary *)customParametersFromXMPPMessage:(id)message;

// Internet
+ (NSString *)getIPAddress;

@end
