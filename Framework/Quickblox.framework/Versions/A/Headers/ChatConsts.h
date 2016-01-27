//
//  Consts.h
//  Quickblox
//
//  Created by IgorKh on 2/6/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

extern NSString *const kPresenceSubscriptionStateNone;
extern NSString *const kPresenceSubscriptionStateTo;
extern NSString *const kPresenceSubscriptionStateFrom;
extern NSString *const kPresenceSubscriptionStateBoth;

extern NSString* const QBChatDialogJoinPrefix;
extern NSString* const QBChatDialogLeavePrefix;
extern NSString* const QBChatDialogOnlineUsersPrefix;
extern NSString* const QBChatDialogOnJoinFailedPrefix;
extern NSString* const QBChatDialogIsTypingPrefix;
extern NSString* const QBChatDialogStopTypingPrefix;
extern NSString* const QBChatDialogOccupantDidJoinPrefix;
extern NSString* const QBChatDialogOccupantDidLeavePrefix;
extern NSString* const QBChatDialogOccupantDidUpdatePrefix;

#define discoItems @"http://jabber.org/protocol/disco#items"
// 561003
#define requestRoomOnlineUsersQueryIDPrefix @"561005"
// 561006

#define qbChatMessageExtraParams @"extraParams"
#define qbChatPresenceExtension @"x"
#define qbChatPresenceExtensionXMLNS @"http://chat.quickblox.com/presence_extension"
