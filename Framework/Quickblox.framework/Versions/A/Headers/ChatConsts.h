//
//  Consts.h
//  Quickblox
//
//  Created by IgorKh on 2/6/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

extern NSString *const kPresenseSubscriptionStateNone;
extern NSString *const kPresenseSubscriptionStateTo;
extern NSString *const kPresenseSubscriptionStateFrom;
extern NSString *const kPresenseSubscriptionStateBoth;


#define discoItems @"http://jabber.org/protocol/disco#items"
#define discoInfo @"http://jabber.org/protocol/disco#info"
#define mucOwner @"http://jabber.org/protocol/muc#owner"
#define mucAdmin @"http://jabber.org/protocol/muc#admin"

// 561003
#define requestRoomOnlineUsersQueryIDPrefix @"561005"
// 561006

#define qbChatMessageExtraParams @"extraParams"
#define qbChatMessageQuickBloxExtension @"quickblox"
#define qbChatPresenceExtension @"x"
#define qbChatPresenceExtensionXMLNS @"http://chat.quickblox.com/presence_extension"
#define qbChatMessageExtraParamSessionID @"sessionID"
#define qbChatMessageExtraParamCallType @"callType"
#define qbChatMessageExtraParamProtocol @"protocol"

// TCP/UDP video/audio packets tags
#define sendUDPAudioDataTag 7007
#define sendUDPVideoDataTag 3007
#define writeTCPAudioDataTag 7001
#define writeTCPVideoDataTag 5001


// TCP socket type
#define qbTCPSocketType1_ControlSocket 1
#define qbTCPSocketType2_DataSocketConnectedDirectToRelay 2
#define qbTCPSocketType3_DataSocketConnectedDirectToTURNServer 3
